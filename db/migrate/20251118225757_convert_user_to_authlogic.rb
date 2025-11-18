class ConvertUserToAuthlogic < ActiveRecord::Migration[8.0]
  def change
    # Rename password_digest to crypted_password for Authlogic
    rename_column :users, :password_digest, :crypted_password

    # Add Authlogic required columns
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_column :users, :single_access_token, :string
    add_column :users, :perishable_token, :string

    # Add admin flag for role-based access
    add_column :users, :admin, :boolean, default: false, null: false

    # Add indexes for Authlogic token columns
    add_index :users, :persistence_token, unique: true
    add_index :users, :single_access_token, unique: true
    add_index :users, :perishable_token, unique: true
  end
end
