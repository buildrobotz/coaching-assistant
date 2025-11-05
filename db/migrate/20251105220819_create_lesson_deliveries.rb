class CreateLessonDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :lesson_deliveries do |t|
      t.references :client, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.datetime :scheduled_for
      t.datetime :sent_at
      t.datetime :completed_at
      t.string :completion_token

      t.timestamps
    end

    add_index :lesson_deliveries, [:client_id, :lesson_id]
    add_index :lesson_deliveries, :status
    add_index :lesson_deliveries, :completion_token, unique: true
  end
end
