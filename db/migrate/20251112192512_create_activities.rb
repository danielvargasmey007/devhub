# Migration: Create activities table for audit trail
class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :record, polymorphic: true, null: false
      t.string :action, null: false

      t.timestamps
    end
    add_index :activities, [ :record_type, :record_id, :created_at ]
  end
end
