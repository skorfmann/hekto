require 'active_record'
require 'active_job'
require 'sqlite3'
require 'securerandom'
require 'json'

# Set up the database connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Define the schema
ActiveRecord::Schema.define do
  create_table :events do |t|
    t.string :name
    t.text :payload
    t.timestamps
  end

  create_table :workflows do |t|
    t.string :name
    t.string :status
    t.text :current_step
    t.datetime :sleep_until
    t.timestamps
  end

  create_table :steps do |t|
    t.string :name
    t.string :status
    t.text :result
    t.string :idempotency_key
    t.belongs_to :workflow
    t.timestamps
  end
end

# Define models
class Event < ActiveRecord::Base
  validates :name, presence: true
end

class Workflow < ActiveRecord::Base
  has_many :steps
  validates :name, presence: true
  validates :status, inclusion: { in: %w[pending running completed cancelled] }
end

class Step < ActiveRecord::Base
  belongs_to :workflow
  validates :name, presence: true
  validates :status, inclusion: { in: %w[pending completed] }
  validates :idempotency_key, presence: true, uniqueness: true
end

class StepExecutor
  def initialize(workflow)
    @workflow = workflow
  end

  def run(name, &block)
    step = @workflow.steps.find_or_create_by!(name:) do |s|
      s.status = 'pending'
      s.idempotency_key = SecureRandom.uuid
    end

    return JSON.parse(step.result, symbolize_names: true) if step.status == 'completed'

    Step.transaction do
      step.lock!
      return JSON.parse(step.result, symbolize_names: true) unless step.status == 'pending'

      result = yield
      step.update!(status: 'completed', result: result.to_json)
      return result
    end
  end

  def sleepUntil(name, time)
    run(name) do
      @workflow.update!(sleep_until: time, current_step: name)
      WakeUpJob.set(wait_until: time).perform_later(@workflow.id)
      { slept_until: time }
    end
  end
end

class WorkflowEngine
  def self.create_function(config, &block)
    workflow = Workflow.create!(name: config[:id], status: 'pending')

    define_singleton_method(config[:id]) do |event|
      ProcessWorkflowJob.perform_later(workflow.id, event.id)
    end
  end

  def self.trigger_event(name, payload)
    event = Event.create!(name:, payload: payload.to_json)
    method_name = name.split('/').last.split('.').first
    if respond_to?(method_name)
      send(method_name, event)
    else
      puts "No workflow found for event: #{name}"
    end
  end
end

class ProcessWorkflowJob < ActiveJob::Base
  def perform(workflow_id, event_id)
    workflow = Workflow.find(workflow_id)
    event = Event.find(event_id)

    return if workflow.status == 'cancelled'

    if workflow.sleep_until && workflow.sleep_until > Time.now
      WakeUpJob.set(wait_until: workflow.sleep_until).perform_later(workflow_id)
      return
    end

    workflow.update!(status: 'running')
    step_executor = StepExecutor.new(workflow)

    workflow_config = WorkflowEngine.method(workflow.name).source_location[0]
    workflow_block = eval(File.read(workflow_config)).last

    workflow_block.call({ event:, step: step_executor })
    workflow.update!(status: 'completed')
  rescue StandardError => e
    puts "Error processing workflow: #{e.message}"
    workflow.update!(status: 'failed')
  end
end

class WakeUpJob < ActiveJob::Base
  def perform(workflow_id)
    workflow = Workflow.find(workflow_id)
    return if workflow.status == 'cancelled' || workflow.status == 'completed'

    ProcessWorkflowJob.perform_later(workflow_id, Event.last.id) # Using last event as a simplification
  end
end

# Set up ActiveJob to run inline (for simplicity in this example)
ActiveJob::Base.queue_adapter = :inline

# Mock push notification service
class PushNotificationService
  def self.push(user_id, message)
    puts "Sending push notification to user #{user_id}: #{message}"
  end
end

# Define a workflow
WorkflowEngine.create_function(
  {
    id: 'schedule-reminder',
    cancelOn: [{
      event: 'tasks/reminder.deleted',
      if: 'async.data.reminderId == event.data.reminderId'
    }]
  }
) do |params|
  event = params[:event]
  step = params[:step]
  data = JSON.parse(event.payload, symbolize_names: true)
  step.sleepUntil('sleep-until-remind-at-time', Time.parse(data[:remindAt]))
  step.run('send-reminder-push') do
    PushNotificationService.push(data[:userId], data[:reminderBody])
    { status: 'sent' }
  end
end

# Trigger the workflow
puts 'Creating reminder:'
WorkflowEngine.trigger_event('tasks/reminder.created', {
                               reminderId: '123',
                               userId: '456',
                               reminderBody: 'Remember to drink water',
                               remindAt: (Time.now + 5).iso8601
                             })

# Wait for a moment
sleep(6)

# Trigger the workflow again (it should execute now)
puts "\nExecuting reminder:"
WorkflowEngine.trigger_event('tasks/reminder.created', {
                               reminderId: '123',
                               userId: '456',
                               reminderBody: 'Remember to drink water',
                               remindAt: (Time.now - 1).iso8601
                             })

# Try to cancel the workflow
puts "\nTrying to cancel reminder:"
WorkflowEngine.trigger_event('tasks/reminder.deleted', {
                               reminderId: '123'
                             })

# Print final status from database
puts "\nFinal status from database:"
Workflow.all.each do |workflow|
  puts "Workflow #{workflow.name}: #{workflow.status}"
  workflow.steps.each do |step|
    puts "  Step #{step.name}: #{step.status} - Result: #{step.result}"
  end
end
