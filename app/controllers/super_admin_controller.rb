class SuperAdminController < ApplicationController
  before_action :require_super_admin

  def users
    @users = User.all
    render inertia: "super_admin/users", props: { users: @users }
  end

  def show_user
    @user = User.find(params[:id])
    render inertia: "super_admin/show_user", props: { user: @user }
  end

  def update_user
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      redirect_to "/super/users", notice: "User updated successfully"
    else
      render inertia: "super_admin/users", props: { 
        users: User.all,
        errors: @user.errors.full_messages
      }
    end
  end

  def orgs
    render inertia: "super_admin/orgs"
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :super_admin, :email_verified_at)
  end
end
