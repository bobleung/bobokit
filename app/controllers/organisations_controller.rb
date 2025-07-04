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
      members: @organisation.members_data
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
    
    # Use service to handle invitation logic
    result = MemberInvitationService.call(@organisation, Current.user, params[:email], params[:role])
    
    if result.success?
      flash[:success] = result.message
    else
      flash[:error] = result.message
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
    
    # Check if member can be removed
    unless member_to_remove.can_be_removed_by?(Current.user)
      if member_to_remove.role == 'owner'
        flash[:error] = "Cannot remove the organisation owner"
      else
        flash[:error] = "Cannot remove yourself from the organisation"
      end
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
    
    # Check if role can be changed
    unless member_to_update.can_change_role_to?(new_role)
      if member_to_update.role == 'owner'
        flash[:error] = "Cannot change the organisation owner's role"
      elsif member_to_update.user == Current.user
        flash[:error] = "Cannot change your own role"
      else
        flash[:error] = "Invalid role specified"
      end
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
