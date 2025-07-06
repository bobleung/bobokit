class CreateOrganisations < ActiveRecord::Migration[8.0]
  def change
    create_table :organisations do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :county
      t.string :postcode
      t.string :country
      t.json :metadata
      t.references :parent, null: true, foreign_key: { to_table: :organisations }
      t.string :code_type
      t.string :code
      t.text :note

      t.timestamps
    end
    
    add_index :organisations, :type
  end
end
