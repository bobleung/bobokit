class EmailVerificationsController < ApplicationController
  allow_unverified_access only: %i[ verify show resend ]

  def show
    render inertia: "email_verification/show"
  end

  def verify
    @user = User.find_by(verification_token: params[:token])

    if @user&.verification_token_valid?
      @user.verify_email!
      start_new_session_for @user
      flash[:success] = "Email verified successfully! Welcome to myLocums."
      redirect_to root_path
    else
      flash[:error] = "Invalid or expired verification link."
      redirect_to new_session_path
    end
  end

  def resend
    if Current.user&.email_verified?
      flash[:notice] = "Your email is already verified."
      redirect_to root_path
    elsif Current.user
      Current.user.regenerate_verification_token
      UserMailer.email_verification(Current.user).deliver_now
      flash[:success] = "Verification email sent."
      redirect_to email_verification_path
    else
      flash[:error] = "Please sign in to resend verification email."
      redirect_to new_session_path
    end
  end
end
