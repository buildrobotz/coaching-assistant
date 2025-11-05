class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.references :course_module, null: false, foreign_key: true
      t.string :title, null: false
      t.string :markdown_file_path, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :lessons, [:course_module_id, :position]
  end
end
