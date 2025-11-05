class CreateCourseModules < ActiveRecord::Migration[7.1]
  def change
    create_table :course_modules do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false

      t.timestamps
    end

    add_index :course_modules, :position
  end
end
