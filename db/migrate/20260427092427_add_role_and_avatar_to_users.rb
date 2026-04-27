class AddRoleAndAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :avatar, :string
  end
end
