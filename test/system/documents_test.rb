require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @document = documents(:one)
  end

  test "visiting the index" do
    visit documents_url
    assert_selector "h1", text: "Documents"
  end

  test "creating a Document" do
    visit documents_url
    click_on "New Document"

    fill_in "Account", with: @document.account_id
    fill_in "Content", with: @document.content
    fill_in "Metadata", with: @document.metadata
    fill_in "Name", with: @document.name
    fill_in "User", with: @document.user_id
    click_on "Create Document"

    assert_text "Document was successfully created"
    assert_selector "h1", text: "Documents"
  end

  test "updating a Document" do
    visit document_url(@document)
    click_on "Edit", match: :first

    fill_in "Account", with: @document.account_id
    fill_in "Content", with: @document.content
    fill_in "Metadata", with: @document.metadata
    fill_in "Name", with: @document.name
    fill_in "User", with: @document.user_id
    click_on "Update Document"

    assert_text "Document was successfully updated"
    assert_selector "h1", text: "Documents"
  end

  test "destroying a Document" do
    visit edit_document_url(@document)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Document was successfully destroyed"
  end
end
