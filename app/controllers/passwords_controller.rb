
class PasswordsController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)

    if user
      PasswordsMailer.with(user: user).reset.deliver_later
    end

    redirect_to new_session_path,
      notice: "If your email exists, password reset instructions have been sent."
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveRecord::RecordNotFound,
         ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path,
      alert: "This password reset link is invalid or expired."
  end

  def update
    @user = User.find_by_password_reset_token!(params[:token])

    if @user.update(password_params)
      redirect_to new_session_path,
        notice: "Password updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound,
         ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path,
      alert: "This password reset link is invalid or expired."
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
