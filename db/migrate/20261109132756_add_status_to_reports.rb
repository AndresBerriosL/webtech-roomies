class AddStatusToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :status, :integer,
               default: 0, null: false
  end
end
