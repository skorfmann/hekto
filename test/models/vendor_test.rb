# == Schema Information
#
# Table name: vendors
#
#  id             :bigint           not null, primary key
#  name           :string
#  address        :text
#  city           :string
#  country        :string
#  metadata       :jsonb
#  sources        :jsonb
#  account_id     :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name_vector    :tsvector
#  address_vector :tsvector
#
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
