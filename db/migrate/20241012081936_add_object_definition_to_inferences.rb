class AddObjectDefinitionToInferences < ActiveRecord::Migration[8.0]
  def change
    add_column :inferences, :object_definition, :text
  end
end
