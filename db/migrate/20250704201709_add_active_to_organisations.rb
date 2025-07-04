class AddActiveToOrganisations < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :active, :boolean, default: true, null: false
  end
end
