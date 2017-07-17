class AddMediaColumnsToExerciseItems < ActiveRecord::Migration
  def change
    add_column :exercise_items, :media_id, :string
    add_column :exercise_items, :media_type, :string
    add_index :exercise_items, :media_id
  end
end
