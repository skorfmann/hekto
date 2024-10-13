require "administrate/field/base"

class JsonbField < Administrate::Field::Base
  def to_s
    data.to_json
  end

  def truncate
    data.to_json.truncate(50)
  end

  def formatted_value
    JSON.pretty_generate(data)
  end

  def selectable_options
    options.fetch(:selectable_options, [])
  end

  def to_partial_path
    "/fields/jsonb_field/#{page}"
  end
end
