class SuperAdminController < ApplicationController
  def users
    @users = User.all
    render inertia: "super_admin/users", props: { users: @users }
  end
  def orgs
    render inertia: "super_admin/orgs"
  end
end
