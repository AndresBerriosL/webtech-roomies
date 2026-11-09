
class AllowNullDescriptionOnListings < ActiveRecord::Migration[8.0]
  def change
    change_column_null :listings, :description, true
  end
end
