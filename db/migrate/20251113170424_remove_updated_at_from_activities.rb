class RemoveUpdatedAtFromActivities < ActiveRecord::Migration[8.0]
  def change
    remove_column :activities, :updated_at, :datetime
  end
end
