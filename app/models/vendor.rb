class Vendor < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  has_many :documents

  # Update tsvector columns before save
  before_save :update_tsvector_columns

  def self.search(name_query, address_query)
    select(Arel.sql(sanitize_sql_array([
                                         "vendors.*,
       ts_rank(name_vector, plainto_tsquery('english', ?)) * similarity(name, ?) as name_rank,
       ts_rank(address_vector, plainto_tsquery('english', ?)) * similarity(address, ?) as address_rank",
                                         name_query, name_query, address_query, address_query
                                       ])))
      .where(Arel.sql(sanitize_sql_array([
                                           "(name_vector @@ plainto_tsquery('english', ?) OR similarity(name, ?) > 0.3) AND
       (address_vector @@ plainto_tsquery('english', ?) OR similarity(address, ?) > 0.3)",
                                           name_query, name_query, address_query, address_query
                                         ])))
      .order(Arel.sql(sanitize_sql_array([
                                           "(ts_rank(name_vector, plainto_tsquery('english', ?)) * similarity(name, ?) +
        ts_rank(address_vector, plainto_tsquery('english', ?)) * similarity(address, ?)) DESC",
                                           name_query, name_query, address_query, address_query
                                         ])))
  end

  private

  def update_tsvector_columns
    self.name_vector = Vendor.generate_tsvector(name)
    self.address_vector = Vendor.generate_tsvector(address)
  end

  def self.generate_tsvector(text)
    ActiveRecord::Base.connection.execute("SELECT to_tsvector('english', #{ActiveRecord::Base.connection.quote(text || '')})").first['to_tsvector']
  end
end
