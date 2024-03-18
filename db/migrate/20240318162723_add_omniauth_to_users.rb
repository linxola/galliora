class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :github_uid
      t.string :google_uid
    end
  end
end
