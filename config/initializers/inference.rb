Anthropic.configure do |config|
  config.access_token = Rails.application.credentials.dig(:anthropic, :api_key)
end