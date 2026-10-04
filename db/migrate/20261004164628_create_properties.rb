class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.bigint :host_id, null: false
      t.references :neighborhood, null: false, foreign_key: true

      t.string :address, null: false
      t.string :property_type, null: false
      t.integer :bedrooms, null: false
      t.integer :bathrooms, null: false
      t.text :shared_spaces

      t.timestamps
    end

    add_index :properties, :host_id
    add_foreign_key :properties, :users, column: :host_id
  end
end