class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true

      t.decimal :monthly_rent, precision: 10, scale: 2, null: false
      t.decimal :deposit, precision: 10, scale: 2, null: false
      t.date :availability_date, null: false
      t.integer :minimum_stay, null: false
      t.boolean :furnished, null: false, default: false
      t.boolean :private_bathroom, null: false, default: false
      t.text :description, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end