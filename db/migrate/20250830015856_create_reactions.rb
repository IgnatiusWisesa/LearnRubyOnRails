class CreateReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reactions do |t|
      t.string :kind
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :reactable, polymorphic: true, null: false, index: false

      t.timestamps
    end

    add_index :reactions, [:reactable_type, :reactable_id]
    add_index :reactions, [:user_id, :reactable_type, :reactable_id, :kind], unique: true, name: "idx_unique_reaction_per_user_reactable_kind"

  end
end
