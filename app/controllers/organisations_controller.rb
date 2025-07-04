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
end
