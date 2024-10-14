require 'json'
require 'json_schemer'
require 'ostruct'

class Document::Receipt < Document
  SCHEMA_PATH = Rails.root.join('app', 'schemas', 'receipt.json.schema')
  METADATA_SCHEMA = JSONSchemer.schema(SCHEMA_PATH)

  validate :validate_metadata_schema

  def parsed
    @parsed ||= build_parsed_object(metadata)
  end

  private

  def build_parsed_object(data)
    case data
    when Hash
      OpenStruct.new(data.transform_values { |v| build_parsed_object(v) })
    when Array
      data.map { |item| build_parsed_object(item) }
    when String
      data =~ /^\d{4}-\d{2}-\d{2}$/ ? Date.parse(data) : data
    when Numeric
      BigDecimal(data.to_s)
    else
      data
    end
  end

  def validate_metadata_schema
    METADATA_SCHEMA.validate(metadata).each do |error|
      field = error['data_pointer'].gsub('/', '.')
      field = field[1..-1] if field.start_with?('.')

      message = case error['type']
                when 'format'
                  "Invalid format for #{field}. Expected #{error['schema']['description']}"
                when 'required'
                  if error['details'] && error['details']['missing_keys']
                    missing_fields = error['details']['missing_keys'].join(', ')
                    "Missing required field(s): #{missing_fields}"
                  else
                    "Missing required field: #{field}"
                  end
                else
                  "Invalid value for #{field}: #{error['details']}"
                end

      errors.add(:metadata, message)
    end
  end
end
