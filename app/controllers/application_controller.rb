class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_proper_protocol
  before_filter :find_states
  
  protected
  
  def ssl_allowed_action?
    (params[:controller] == 'sessions' && ['new', 'create'].
      include?(params[:action])) || (params[:controller] == 'registrations' &&
      ['new', 'create', 'edit', 'update'].include?(params[:action])) ||
      (params[:controller] == 'omniauth_callbacks') ||
      (params[:controller] == 'devise/passwords')
  end
  
  def ensure_proper_protocol
    #print Rails.logger.info(params[:controller])
    #print Rails.logger.info(params[:action])
    hostname = request.host
    hostname = "blackops.wz.hasbro.com" if hostname == "blackops" 
    if hostname == "blackops.wz.hasbro.com"
      if request.ssl? && !ssl_allowed_action?
        redirect_to "http://" + hostname + request.fullpath
      elsif !request.ssl? && ssl_allowed_action?
        redirect_to "https://" + hostname + request.fullpath
      end
    end
  end
  
  def after_sign_in_path_for(resource)
    root_url(:protocol => 'http')
  end
  
  def after_sign_out_path_for(resource)
    root_url(:protocol => 'http')
  end
  
  private
  
  def authorize_admin!
    authenticate_user! 
    unless current_user.admin?
      flash[:alert] = "You must be an admin to do that."
      redirect_to root_path
    end
  end
  
  def find_states
    @states = State.all
  end
end