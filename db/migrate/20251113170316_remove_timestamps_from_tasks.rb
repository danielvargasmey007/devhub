class RemoveTimestampsFromTasks < ActiveRecord::Migration[8.1]
  def change
    remove_column :tasks, :created_at, :datetime
    remove_column :tasks, :updated_at, :datetime
  end
end
