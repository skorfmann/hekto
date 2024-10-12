require 'test_helper'
require 'vcr'

class DocumentProcessingWorkflowPromptTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @user = users(:one)
    @document = documents(:one)
    @prompt = DocumentProcessingWorkflowPrompt.new()
  end

  test "create_summary generates a summary using the correct template and AI service in German" do
    VCR.use_cassette("document_processing_workflow/create_summary_de") do
      I18n.with_locale(:de) do
        summary = @prompt.create_summary(@document)

        assert_match /Rechnung .+ für .+, \d+€, fällig am \d{2}\.\d{2}\.\d{4}/, summary
        assert summary.is_a?(String)
        assert summary.length > 10
      end
    end
  end

  test "create_summary generates a summary using the correct template and AI service in English" do
    VCR.use_cassette("document_processing_workflow/create_summary_en") do
      I18n.with_locale(:en) do
        summary = @prompt.create_summary(@document)

        assert_match /Invoice .+ for .+, \$\d+(?:\.\d{2})? due on [A-Z][a-z]{2} \d{1,2}, \d{4}/, summary
        assert summary.is_a?(String)
        assert summary.length > 10
      end
    end
  end

  test "create_summary generates a summary and creates an inference model" do
    VCR.use_cassette("document_processing_workflow/create_summary_with_inference_model") do
      assert_difference 'Inference::Inference.count', 1 do
        @prompt.create_summary(@document)
      end
    end
  end
end
