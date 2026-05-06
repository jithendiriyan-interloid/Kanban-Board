class AddProfileFieldsAndDeletedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :address, :text
    add_column :users, :alternate_email, :string
    add_column :users, :deleted_at, :datetime

    add_index :users, :deleted_at
  end
end
