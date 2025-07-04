class UserContextController < ApplicationController
  def switch_context
    entity_id = params[:entity_id]
    
    if switch_entity_context(entity_id)
      flash[:success] = "Switched to #{@current_context.current_entity.display_name}"
    else
      flash[:error] = "Unable to switch to that entity"
    end
    
    redirect_back(fallback_location: root_path)
  end
end