class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :timezone, default: "America/New_York"
      t.string :preferred_send_time, default: "09:00"
      t.integer :current_streak, default: 0
      t.integer :longest_streak, default: 0

      t.timestamps
    end

    add_index :clients, :email, unique: true
  end
end
