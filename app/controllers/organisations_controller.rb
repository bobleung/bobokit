class OrganisationsController < ApplicationController
  def new
    render inertia: "organisations/new", props: {
      organisation_types: [ "Agency", "Client", "Locum" ]
    }
  end

  def create
    organisation_params = params.require(:organisation).permit(:type, :name, :email, :phone, :address_line1, :address_line2, :city, :county, :postcode, :country, :code_type, :code, :note)

    # Create the organisation based on type
    organisation_class = organisation_params[:type].constantize
    @organisation = organisation_class.new(organisation_params.except(:type))

    if @organisation.save
      # Create owner membership for current user
      Membership.create!(
        user: Current.user,
        entity: @organisation,
        role: :owner
      )

      # Switch to the new organisation
      switch_entity_context(@organisation.id)

      flash[:success] = "#{@organisation.display_name} created successfully!"
      redirect_to root_path
    else
      render inertia: "organisations/new", props: {
        organisation_types: [ "Agency", "Client", "Locum" ],
        errors: @organisation.errors.as_json,
        organisation: organisation_params
      }
    end
  end

  def show
    @organisation = Organisation.find(params[:id])

    # Check if user has access to this organisation
    membership = Current.user.memberships.find_by(entity: @organisation)

    unless membership
      flash[:error] = "You don't have access to that organisation"
      redirect_to root_path
      return
    end

    render inertia: "organisations/show", props: {
      organisation: @organisation,
      membership: membership,
      members: @organisation.memberships.includes(:user).map do |m|
        {
          id: m.id,
          role: m.role,
          invite_accepted: m.invite_accepted,
          pending_invite: m.pending_invite?,
          display_name: m.display_name,
          display_email: m.display_email,
          user: m.user&.sanitised
        }
      end
    }
  end

  def edit
    @organisation = Organisation.find(params[:id])

    # Check if user has access to this organisation
    membership = Current.user.memberships.find_by(entity: @organisation)

    unless membership
      flash[:error] = "You don't have access to that organisation"
      redirect_to root_path
      return
    end

    render inertia: "organisations/edit", props: {
      organisation: @organisation,
      membership: membership,
      organisation_types: [ "Agency", "Client", "Locum" ]
    }
  end

  def update
    @organisation = Organisation.find(params[:id])

    # Check if user has access to this organisation
    membership = Current.user.memberships.find_by(entity: @organisation)

    unless membership
      flash[:error] = "You don't have access to that organisation"
      redirect_to root_path
      return
    end

    organisation_params = params.require(:organisation).permit(:name, :email, :phone, :address_line1, :address_line2, :city, :county, :postcode, :country, :code_type, :code, :note)

    if @organisation.update(organisation_params)
      flash[:success] = "#{@organisation.display_name} updated successfully!"
      redirect_to organisation_path(@organisation)
    else
      render inertia: "organisations/edit", props: {
        organisation: @organisation,
        membership: membership,
        organisation_types: [ "Agency", "Client", "Locum" ],
        errors: @organisation.errors
      }
    end
  end
  
  def invite_member
    @organisation = Organisation.find(params[:id])
    
    # Check if user has permission to invite
    membership = Current.user.memberships.accepted.find_by(entity: @organisation)
    
    unless membership&.can_manage_users?
      flash[:error] = "You don't have permission to invite members"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Check if organisation type allows members
    if @organisation.type == 'Locum'
      flash[:error] = "Locum profiles cannot have additional members"
      redirect_to organisation_path(@organisation)
      return
    end
    
    email = params[:email]&.strip&.downcase
    role = params[:role] || 'member'
    
    if email.blank?
      flash[:error] = "Email address is required"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Check if user already exists and has membership
    existing_user = User.find_by(email_address: email)
    if existing_user
      existing_membership = existing_user.memberships.find_by(entity: @organisation)
      if existing_membership
        if existing_membership.invite_accepted?
          flash[:error] = "#{email} is already a member of this organisation"
        else
          flash[:error] = "#{email} already has a pending invitation"
        end
        redirect_to organisation_path(@organisation)
        return
      end
    end
    
    # Check for existing pending invitation
    existing_invite = Membership.pending.for_email(email).find_by(entity: @organisation)
    if existing_invite
      flash[:error] = "#{email} already has a pending invitation"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Create the invitation
    invitation = Membership.new(
      entity: @organisation,
      invited_email: email,
      role: role,
      invite_accepted: false
    )
    
    if existing_user
      # User exists, link them immediately but leave as pending for acceptance
      invitation.user = existing_user
      invitation.invited_email = nil
    end
    
    if invitation.save
      # TODO: Send invitation email
      flash[:success] = "Invitation sent to #{email}"
    else
      flash[:error] = "Failed to send invitation: #{invitation.errors.full_messages.join(', ')}"
    end
    
    redirect_to organisation_path(@organisation)
  end
  
  def remove_member
    @organisation = Organisation.find(params[:id])
    
    # Check if user has permission to remove members
    membership = Current.user.memberships.accepted.find_by(entity: @organisation)
    
    unless membership&.can_manage_users?
      flash[:error] = "You don't have permission to remove members"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Find the member to remove
    member_to_remove = @organisation.memberships.find_by(id: params[:member_id])
    
    unless member_to_remove
      flash[:error] = "Member not found or has already been removed"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Cannot remove owner
    if member_to_remove.role == 'owner'
      flash[:error] = "Cannot remove the organisation owner"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Cannot remove yourself
    if member_to_remove.user == Current.user
      flash[:error] = "Cannot remove yourself from the organisation"
      redirect_to organisation_path(@organisation)
      return
    end
    
    member_name = member_to_remove.display_name
    
    if member_to_remove.destroy
      flash[:success] = "#{member_name} has been removed from the organisation"
    else
      flash[:error] = "Failed to remove member"
    end
    
    redirect_to organisation_path(@organisation)
  end
  
  def change_member_role
    @organisation = Organisation.find(params[:id])
    
    # Check if user has permission to change roles
    membership = Current.user.memberships.accepted.find_by(entity: @organisation)
    
    unless membership&.can_manage_users?
      flash[:error] = "You don't have permission to change member roles"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Find the member to update
    member_to_update = @organisation.memberships.find_by(id: params[:member_id])
    
    unless member_to_update
      flash[:error] = "Member not found"
      redirect_to organisation_path(@organisation)
      return
    end
    
    new_role = params[:role]
    
    # Validate role
    unless %w[member admin].include?(new_role)
      flash[:error] = "Invalid role specified"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Cannot change owner role
    if member_to_update.role == 'owner'
      flash[:error] = "Cannot change the organisation owner's role"
      redirect_to organisation_path(@organisation)
      return
    end
    
    # Cannot change your own role
    if member_to_update.user == Current.user
      flash[:error] = "Cannot change your own role"
      redirect_to organisation_path(@organisation)
      return
    end
    
    old_role = member_to_update.role
    member_name = member_to_update.display_name
    
    if member_to_update.update(role: new_role)
      flash[:success] = "#{member_name} has been changed from #{old_role} to #{new_role}"
    else
      flash[:error] = "Failed to update member role"
    end
    
    redirect_to organisation_path(@organisation)
  end
end
