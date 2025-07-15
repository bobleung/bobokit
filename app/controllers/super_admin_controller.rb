class SuperAdminController < ApplicationController
  before_action :require_super_admin

  def users
    @users = User.unscoped.all

    # Filter by search term if provided
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @users = @users.where(
        @users.arel_table[:first_name].matches(search_term)
          .or(@users.arel_table[:last_name].matches(search_term))
          .or(@users.arel_table[:email_address].matches(search_term))
      )
    end

    render inertia: "super_admin/users/index", props: {
      users: @users,
      search: params[:search] || ""
    }
  end

  def create_user
    @user = User.new(user_params)

    if @user.save
      redirect_to "/super/users", notice: "User created successfully"
    else
      flash[:error] = @user.errors.full_messages
      render inertia: "super_admin/users/index", props: {
        users: User.unscoped.all
      }
    end
  end

  def update_user
    @user = User.unscoped.find(params[:id])

    # Filter out empty password fields to avoid updating password when not intended
    update_params = user_params
    if update_params[:password].blank?
      update_params = update_params.except(:password, :password_confirmation)
    end

    if @user.update(update_params)
      redirect_to "/super/users", notice: "User updated successfully"
    else
      flash[:error]=@user.errors.full_messages
      render inertia: "super_admin/users/index", props: {
        users: User.unscoped.all
      }
    end
  end

  def destroy_user
    @user = User.unscoped.find(params[:id])

    if @user.destroy
      redirect_to "/super/users", notice: "User deleted successfully"
    else
      redirect_to "/super/users", alert: "Failed to delete user"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/super/users/index", alert: "User not found"
  end

  def orgs
    @type = params[:type].presence || "Client"
    @orgs = Organisation.where(type: @type).order(:name)

    render inertia: "super_admin/orgs/index", props: {
      orgs: @orgs,
      type: @type
    }
  end

  def update_org
    @org = Organisation.find(params[:id])
    if @org.update(org_params)
      # Return success response with updated data
      flash[:success]="Org updated"
      render inertia: "super_admin/orgs/index", props: {
        orgs: Organisation.where(type: @org.type).order(:name),
        type: @org.type
      }
    else
      flash[:error]=@org.errors.full_messages
      # Return error response
      render inertia: "super_admin/orgs/index", props: {
        orgs: Organisation.where(type: @org.type).order(:name),
        type: @org.type
      }
    end
  end

  def destroy_org
    @org = Organisation.find(params[:id])
    if @org.destroy
      flash[:success]="Org Deleted"
      render inertia: "super_admin/orgs/index", props: {
        orgs: Organisation.where(type: params[:type].presence || "Client").order(:name),
        type: params[:type].presence || "Client"
      }
    else
      flash[:error]=@org.errors.full_messages
      render inertia: "super_admin/orgs/index", props: {
        orgs: Organisation.where(type: params[:type].presence || "Client").order(:name),
        type: params[:type].presence || "Client",
        errors: @org.errors.full_messages
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :super_admin, :email_verified_at, :deactivated, :password, :password_confirmation)
  end

  def org_params
    params.require(:organisation).permit(:name, :email, :phone, :address_line1, :address_line2, :city, :county, :postcode, :country, :code_type, :code, :note, :active)
  end
end
