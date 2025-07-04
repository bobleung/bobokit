class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entity, null: false, foreign_key: { to_table: :organisations }
      t.integer :role, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :memberships, [:user_id, :entity_id], unique: true
  end
end
