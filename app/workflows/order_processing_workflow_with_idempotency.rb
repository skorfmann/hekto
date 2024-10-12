class OrderProcessingWorkflowWithIdempotency < DurableFlow::Workflow
  def execute
    random_number = step :generate_random_number do
      rand(1000)
    end

    sleep_for :some_time, 1.hour

    step :normalize_raw_csv do
      [{
        'Name' => 'John Doe',
        'Email' => 'john@example.com',
        'RandomNumber' => random_number
      }].map { |row| row.transform_keys(&:downcase) }
    end
  end
end