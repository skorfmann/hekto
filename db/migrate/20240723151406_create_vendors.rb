class CreateVendors < ActiveRecord::Migration[7.2]
  def change
    create_table :vendors do |t|
      t.string :name
      t.text :address
      t.string :city
      t.string :country
      t.jsonb :metadata
      t.jsonb :sources
      t.belongs_to :account, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :documents, :vendor, foreign_key: true
  end
end
