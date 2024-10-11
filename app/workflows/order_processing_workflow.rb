
class OrderProcessingWorkflow < DurableFlow::Workflow
  def execute
    rows = step :parse_csv do
      [{
        'Name' => 'John Doe',
        'Email' => 'john@example.com'
      }]
    end

    step :normalize_raw_csv do
      rows.map { |row| row.transform_keys(&:downcase) }
    end
  end
end