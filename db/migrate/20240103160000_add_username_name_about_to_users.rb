class AddUsernameNameAboutToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :username, null: false, default: ''
      t.string :name
      t.string :about
    end

    add_index :users, :username, unique: true
  end
end
