class AddMediaIdColumnToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :media_id, :string
    add_column :exercises, :media_type, :string
    add_index :exercises, :media_id
  end
end
