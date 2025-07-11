module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :require_email_verification
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
    
    def allow_unverified_access(**options)
      skip_before_action :require_email_verification, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end
    
    def require_email_verification
      return unless Rails.application.config.require_email_verification
      
      if Current.user && !Current.user.email_verified?
        redirect_to email_verification_path
      end
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      return unless cookies.signed[:session_id]
      
      session = Session.find_by(id: cookies.signed[:session_id])
      return unless session
      
      # Check if the user is deactivated (using unscoped to bypass default scope)
      user = User.unscoped.find_by(id: session.user_id)
      if user&.deactivated?
        session.destroy
        cookies.delete(:session_id)
        return nil
      end
      
      session
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
