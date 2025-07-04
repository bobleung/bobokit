class MemberInvitationService
  class Result
    attr_reader :message
    
    def initialize(success, message)
      @success = success
      @message = message
    end
    
    def success?
      @success
    end
  end

  def self.call(organisation, inviting_user, email, role)
    new(organisation, inviting_user, email, role).call
  end

  def initialize(organisation, inviting_user, email, role)
    @organisation = organisation
    @inviting_user = inviting_user
    @email = email&.strip&.downcase
    @role = role || 'member'
  end

  def call
    # Validate email
    return failure("Email address is required") if @email.blank?
    
    # Check if organisation type allows members
    unless @organisation.can_have_members?
      return failure("Locum profiles cannot have additional members")
    end
    
    # Check if user already exists and has membership
    existing_user = User.find_by(email_address: @email)
    if existing_user
      existing_membership = existing_user.memberships.find_by(entity: @organisation)
      if existing_membership
        if existing_membership.invite_accepted?
          return failure("#{@email} is already a member of this organisation")
        else
          return failure("#{@email} already has a pending invitation")
        end
      end
    end
    
    # Check for existing pending invitation
    existing_invite = Membership.pending.for_email(@email).find_by(entity: @organisation)
    if existing_invite
      return failure("#{@email} already has a pending invitation")
    end
    
    # Create the invitation
    invitation = Membership.new(
      entity: @organisation,
      invited_email: @email,
      role: @role,
      invite_accepted: false
    )
    
    if existing_user
      # User exists, link them immediately but leave as pending for acceptance
      invitation.user = existing_user
      invitation.invited_email = nil
    end
    
    if invitation.save
      # TODO: Send invitation email
      success("Invitation sent to #{@email}")
    else
      failure("Failed to send invitation: #{invitation.errors.full_messages.join(', ')}")
    end
  end

  private

  def success(message)
    Result.new(true, message)
  end

  def failure(message)
    Result.new(false, message)
  end
end