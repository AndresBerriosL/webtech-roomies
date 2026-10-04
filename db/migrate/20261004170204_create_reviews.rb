class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :visit,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }

      t.integer :rating, null: false
      t.text :comment, null: false

      t.timestamps
    end
  end
end