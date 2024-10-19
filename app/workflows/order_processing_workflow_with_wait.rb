class OrderProcessingWorkflowWithWait < DurableFlow::Workflow
  def execute(event)
    rows = step :parse_csv do
      [{
        'Name' => 'John Doe',
        'Email' => 'john@example.com'
      }]
    end

    sleep_for :the_end_of_time, 1.hour

    step :normalize_raw_csv do
      rows.map { |row| row.transform_keys(&:downcase) }
    end
  end
end