class CreateProfileUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_users do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :full_name
      t.text :address

      t.timestamps
    end
  end
end
