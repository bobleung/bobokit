class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  allow_unverified_access only: %i[ destroy ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    render inertia: "users/login", props: { errors: {} }
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      
      # Link any pending invites for this user's email
      linked_count = user.link_pending_invites!
      if linked_count > 0
        flash[:notice] = "You have #{linked_count} pending organisation invitation#{linked_count > 1 ? 's' : ''}"
      end
      
      redirect_to after_authentication_url
    else
      render inertia: "users/login", props: {
        errors: { authentication: [ "Invalid email or password" ] }
      }
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
