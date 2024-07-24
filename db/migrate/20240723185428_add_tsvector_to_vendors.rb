class AddTsvectorToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :name_vector, :tsvector
    add_column :vendors, :address_vector, :tsvector

    add_index :vendors, :name_vector, using: :gin
    add_index :vendors, :address_vector, using: :gin
  end
end
