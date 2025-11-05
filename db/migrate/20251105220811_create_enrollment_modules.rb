class CreateEnrollmentModules < ActiveRecord::Migration[7.1]
  def change
    create_table :enrollment_modules do |t|
      t.references :client_enrollment, null: false, foreign_key: true
      t.references :course_module, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :enrollment_modules, [:client_enrollment_id, :position]
  end
end
