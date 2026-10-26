class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: params[:user_id]) ||
                      User.order(:id).first
  end

  def default_url_options
    current_user ? { user_id: current_user.id } : {}
  end
end