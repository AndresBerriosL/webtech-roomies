class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.bigint :reporter_id, null: false
      t.references :listing, null: false, foreign_key: true
      t.text :reason, null: false

      t.timestamps
    end

    add_index :reports, :reporter_id
    add_foreign_key :reports, :users, column: :reporter_id
  end
end