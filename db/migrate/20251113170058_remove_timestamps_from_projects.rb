class RemoveTimestampsFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :created_at, :datetime
    remove_column :projects, :updated_at, :datetime
  end
end
