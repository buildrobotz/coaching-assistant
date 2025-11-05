class CreateDailyCompletions < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_completions do |t|
      t.references :client, null: false, foreign_key: true
      t.date :completion_date, null: false
      t.integer :lessons_completed_count, null: false, default: 0

      t.timestamps
    end

    add_index :daily_completions, [:client_id, :completion_date], unique: true
  end
end
