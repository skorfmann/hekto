class AddStatusToInferences < ActiveRecord::Migration[8.0]
  def change
    add_column :inferences, :status, :integer
  end
end
