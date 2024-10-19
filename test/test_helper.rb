ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"
require_relative 'support/file_attachment_helper'

# Uncomment to view full stack trace in tests
# Rails.backtrace_cleaner.remove_silencers!

if defined?(Sidekiq)
  require "sidekiq/testing"
  Sidekiq.logger.level = Logger::WARN
end

if defined?(SolidQueue)
  SolidQueue.logger.level = Logger::WARN
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def json_response
      JSON.decode(response.body)
    end

    include FileAttachmentHelper
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    def switch_account(account)
      patch "/accounts/#{account.id}/switch"
    end
  end
end

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: [
    "chromedriver.storage.googleapis.com",
    "rails-app",
    "selenium"
  ]
})

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock, :faraday
  # config.before_http_request do |req|
  #   puts req.uri
  #   puts req.body
  #   puts req.headers
  # end

  config.debug_logger = File.open(Rails.root.join('log', 'vcr_debug.log'), 'w')

  config.before_record do |interaction|
    # Remove sensitive headers
    interaction.request.headers.delete('Authorization')
    interaction.request.headers.delete('X-Api-Key')

    # Optionally, you can also modify the recorded response
    # interaction.response.body = 'modified response'
  end

  config.default_cassette_options = {
    record: :once,
    record_on_error: false,
    match_requests_on: [:method, :uri],
    allow_unused_http_interactions: true
  }
end
