class MembershipsController < ApplicationController
  def accept
    membership = Current.user.memberships.pending.find(params[:id])
    
    if membership.update(invite_accepted: true)
      # Switch to the newly accepted organisation
      switch_entity_context(membership.entity_id)
      flash[:success] = "Welcome to #{membership.entity.display_name}!"
      redirect_to root_path
    else
      flash[:error] = "Failed to accept invitation"
      redirect_back(fallback_location: root_path)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Invitation not found or already processed"
    redirect_back(fallback_location: root_path)
  end
  
  def decline
    membership = Current.user.memberships.pending.find(params[:id])
    
    if membership.destroy
      flash[:notice] = "Invitation to #{membership.entity.name} declined"
    else
      flash[:error] = "Failed to decline invitation"
    end
    
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Invitation not found or already processed"
    redirect_back(fallback_location: root_path)
  end
end