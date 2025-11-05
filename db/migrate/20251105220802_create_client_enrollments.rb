class CreateClientEnrollments < ActiveRecord::Migration[7.1]
  def change
    create_table :client_enrollments do |t|
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
