class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.timestamp :start, null: false
      t.timestamp :end, null: false
      t.integer :break_minutes

      t.timestamp :actual_start
      t.timestamp :actual_end
      t.integer :actual_break_minutes

      t.integer :client_pays
      t.integer :locum_gets
      t.integer :agency_gets

      t.text :notes_job
      t.text :notes_client
      t.text :notes_agency

      t.references :agency, null: true, foreign_key: { to_table: :organisations }
      t.references :client, null: false, foreign_key: { to_table: :organisations }
      t.references :locum, null: true, foreign_key: { to_table: :organisations }

      t.string :owned_by, null: false

      t.timestamps
    end

    add_index :jobs, :start
    add_index :jobs, :end
    add_index :jobs, :owned_by
  end
end
