
class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern
  helper_method :current_user

  rescue_from Pundit::NotAuthorizedError,
              with: :user_not_authorized

  private

  def current_user
    resume_session&.user
  end

  def user_not_authorized
    redirect_to root_path,
      alert: "You are not authorized to perform this action.",
      status: :see_other
  end
end
