class UpdateMembershipsForInvitations < ActiveRecord::Migration[8.0]
  def change
    # Add invitation-specific columns
    add_column :memberships, :invited_email, :string
    add_column :memberships, :invite_accepted, :boolean, default: false
    
    # Make user_id nullable for pending invites
    change_column_null :memberships, :user_id, true
    
    # Remove active column as we're replacing it with invite_accepted
    remove_column :memberships, :active, :boolean
    
    # Add index for email lookups
    add_index :memberships, :invited_email
    
    # Update existing memberships to be accepted
    reversible do |dir|
      dir.up do
        execute "UPDATE memberships SET invite_accepted = true WHERE user_id IS NOT NULL"
      end
    end
  end
end