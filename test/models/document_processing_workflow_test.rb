require 'test_helper'

class DocumentProcessingWorkflowTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @document = documents(:one)
    @document.file.attach(io: File.open(Rails.root.join('test', 'fixtures', 'files', 'test.pdf')),
                          filename: 'test.pdf', content_type: 'application/pdf')
    @workflow = DocumentProcessingWorkflow.new(@document)
  end

  test 'initial state is pending' do
    assert_equal 'pending', @workflow.current_state
  end

  test 'has all defined states' do
    expected_states = %w[pending processing summarizing completed failed]
    assert_equal expected_states.sort, DocumentProcessingWorkflow.states.map(&:to_s).sort
  end

  test 'can transition from pending to processing with valid file' do
    assert @workflow.can_transition_to?(:processing)
    assert_changes -> { @workflow.current_state }, from: 'pending', to: 'processing' do
      @workflow.transition_to!(:processing)
    end
  end

  test 'cannot transition from pending to processing without file' do
    @document.file.purge # Remove the attached file
    @workflow = DocumentProcessingWorkflow.new(@document) # Create a new workflow with the updated document
    refute @workflow.can_transition_to?(:processing)
  end

  test 'enqueues DocumentProcessingJob after transitioning to processing' do
    assert_enqueued_with(job: DocumentProcessingJob, args: [@document.id]) do
      @workflow.transition_to!(:processing)
    end
  end

  test 'can transition from processing to summarizing' do
    @workflow.transition_to!(:processing)
    assert_changes -> { @workflow.current_state }, from: 'processing', to: 'summarizing' do
      @workflow.transition_to!(:summarizing)
    end
  end

  test 'enqueues DocumentSummaryJob after transitioning to summarizing' do
    @workflow.transition_to!(:processing)
    assert_enqueued_with(job: DocumentSummaryJob, args: [@document.id]) do
      @workflow.transition_to!(:summarizing)
    end
  end

  test 'can transition from summarizing to completed' do
    @workflow.transition_to!(:processing)
    @workflow.transition_to!(:summarizing)
    assert_changes -> { @workflow.current_state }, from: 'summarizing', to: 'completed' do
      @workflow.transition_to!(:completed)
    end
  end

  test 'can transition to failed from any state' do
    assert @workflow.can_transition_to?(:failed)
    @workflow.transition_to!(:processing)
    assert @workflow.can_transition_to?(:failed)
    @workflow.transition_to!(:summarizing)
    assert @workflow.can_transition_to?(:failed)
  end
end
