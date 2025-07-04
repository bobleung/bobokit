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
          active: m.active,
          user: m.user.sanitised
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
end
