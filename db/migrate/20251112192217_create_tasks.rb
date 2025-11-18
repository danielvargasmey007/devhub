# Migration: Create tasks table with polymorphic assignee
class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.references :project, null: false, foreign_key: true
      t.references :assignee, polymorphic: true, null: true

      t.timestamps
    end
    add_index :tasks, :status
    add_index :tasks, [ :assignee_type, :assignee_id ]
  end
end
