class SuperAdminController < ApplicationController
  before_action :require_super_admin

  def users
    @users = User.unscoped.all
    render inertia: "super_admin/users", props: { users: @users }
  end

  def show_user
    @user = User.unscoped.find(params[:id])
    render inertia: "super_admin/show_user", props: { user: @user }
  end

  def update_user
    @user = User.unscoped.find(params[:id])

    if @user.update(user_params)
      redirect_to "/super/users", notice: "User updated successfully"
    else
      flash[:error]=@user.errors.full_messages
      render inertia: "super_admin/users", props: {
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
    redirect_to "/super/users", alert: "User not found"
  end

  def orgs
    render inertia: "super_admin/orgs"
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :super_admin, :email_verified_at, :deactivated)
  end
end
