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
    render inertia: "super_admin/orgs/index"
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :super_admin, :email_verified_at, :deactivated, :password, :password_confirmation)
  end
end
