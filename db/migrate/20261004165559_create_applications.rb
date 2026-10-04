class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true
      t.bigint :seeker_id, null: false

      t.text :message, null: false
      t.date :move_in_date, null: false
      t.integer :intended_stay, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :applications, :seeker_id
    add_foreign_key :applications, :users, column: :seeker_id

    add_index :applications,
              [:listing_id, :seeker_id],
              unique: true
  end
end