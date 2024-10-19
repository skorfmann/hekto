class OrderProcessingWorkflowWithConditionalWait < DurableFlow::Workflow
  def execute(event)
    rows = step :parse_csv do
      [{
        'Name' => 'John Doe',
        'Email' => 'john@example.com'
      }]
    end

    if rows.length > 1
      sleep_for :the_end_of_time, 1.hour
    end

    step :normalize_raw_csv do
      rows.map { |row| row.transform_keys(&:downcase) }
    end
  end
end