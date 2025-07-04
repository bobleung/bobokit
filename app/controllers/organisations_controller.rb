class OrganisationsController < ApplicationController
  def new
    render inertia: "organisations/new", props: {
      organisation_types: ['Agency', 'Client', 'Locum']
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
        organisation_types: ['Agency', 'Client', 'Locum'],
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
      organisation: @organisation.as_json(include: :memberships),
      membership: membership.as_json,
      members: @organisation.memberships.includes(:user).as_json(include: :user)
    }
  end
end