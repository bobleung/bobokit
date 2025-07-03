class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    render inertia: "users/signup"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      Rails.logger.info "██ >> Sign up success"
      redirect_to root_path
    else
      Rails.logger.info "██ >> Sign up failed"
      Rails.logger.info @user.errors.inspect
      redirect_to new_user_path
    end
  end

  private
  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
