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

  def orgs
    render inertia: "super_admin/orgs"
  end
end
