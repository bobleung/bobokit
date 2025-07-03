class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  allow_unverified_access only: %i[ profile update_profile ]

  def new
    user_data = params[:user] || {}
    render inertia: "users/signup", props: { user: user_data }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.email_verification(@user).deliver_now
      start_new_session_for @user
      Rails.logger.info "██ >> Sign up success"
      flash[:success] = "Account created! Please check your email to verify your account."
      redirect_to email_verification_path
    else
      Rails.logger.info "██ >> Sign up failed"
      Rails.logger.info @user.errors.inspect
      render inertia: "users/signup", props: {
        user: user_params,
        errors: @user.errors
      }
    end
  end

  def profile
    render inertia: "users/profile", props: { user: Current.user.sanitised }
  end

  def update_profile
    if Current.user.update(profile_params)
      flash[:success] = "Profile updated successfully"
      redirect_to profile_path
    else
      render inertia: "users/profile", props: {
        user: Current.user.sanitised,
        errors: Current.user.errors
      }
    end
  end

  private
  def user_params
    params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])
  end

  def profile_params
    permitted_params = params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])

    # Remove password fields if they're blank (user doesn't want to change password)
    if permitted_params[:password].blank?
      permitted_params.except(:password, :password_confirmation)
    else
      permitted_params
    end
  end
end
