require 'test_helper'

class VendorTest < ActiveSupport::TestCase
  setup do
    @vendor1 = Vendor.create!(
      name: 'EDEKA Niemerszein',
      address: 'Hallerstraße 78, 20146 Hamburg',
      account: accounts(:one)
    )
    @vendor2 = Vendor.create!(
      name: 'EDEKA Niemerszein & Co.KG (GmbH & Co.)',
      address: 'Hallerstraße 78, 20146 Hamburg',
      account: accounts(:one)
    )
    @vendor3 = Vendor.create!(
      name: 'Unrelated Store',
      address: 'Eppendorfer Weg 183, 20253 Hamburg',
      account: accounts(:one)
    )
  end

  test 'search returns ranked matches' do
    results = Vendor.search('Niemerszein', 'Hallerstraße Hamburg')
    assert_equal [@vendor1, @vendor2], results.to_a
  end

  test 'search handles slight variations' do
    results = Vendor.search('EDEKA Niemerzein', 'Hallerstrasse Hamburg') # Misspelled
    puts results.to_a
    assert_includes results, @vendor1
    assert_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test 'search handles additional words' do
    results = Vendor.search('EDEKA Niemerszein & Co KG', 'Hallerstraße 78 Hamburg')
    assert_includes results, @vendor1
    assert_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test "search doesn't match unrelated names" do
    results = Vendor.search('Rewe Supermarkt', 'Eppendorfer Weg Hamburg')
    puts results.to_a.first.inspect
    assert_not_includes results, @vendor1
    assert_not_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test 'search is case insensitive' do
    results = Vendor.search('edeka niemerszein', 'hallerstraße hamburg')
    assert_includes results, @vendor1
    assert_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test 'search handles partial matches' do
    results = Vendor.search('Niemerszein', 'Hamburg')
    assert_includes results, @vendor1
    assert_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test 'search_by_name returns correct results' do
    results = Vendor.search_by_name('EDEKA')
    assert_includes results, @vendor1
    assert_includes results, @vendor2
    assert_not_includes results, @vendor3
  end

  test 'search_by_address returns correct results' do
    results = Vendor.search_by_address('Eppendorfer')
    assert_not_includes results, @vendor1
    assert_not_includes results, @vendor2
    assert_includes results, @vendor3
  end

  test 'search_similar returns same results as search' do
    search_results = Vendor.search('EDEKA Niemerszein', 'Hamburg')
    similar_results = Vendor.search_similar('EDEKA Niemerszein', 'Hamburg')
    assert_equal search_results.to_a, similar_results.to_a
  end

  test 'search with empty address query' do
    results = Vendor.search('EDEKA', '')
    assert_empty results
  end

  test 'search with empty name query' do
    results = Vendor.search('', 'Hamburg')
    assert_empty results
  end

  test 'search with both queries empty returns empty results' do
    results = Vendor.search('', '')
    assert_empty results
  end
end
