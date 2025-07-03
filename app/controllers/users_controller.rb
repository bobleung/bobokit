class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    user_data = params[:user] || {}
    render inertia: "users/signup", props: { user: user_data }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Rails.logger.info "██ >> Sign up success"
      redirect_to root_path
    else
      Rails.logger.info "██ >> Sign up failed"
      Rails.logger.info @user.errors.inspect
      render inertia: "users/signup", props: {
        user: user_params,
        errors: @user.errors
      }
    end
  end

  private
  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
