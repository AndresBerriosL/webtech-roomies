
class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email = @user.email.to_s.strip.downcase
    @user.role = :member

    if @user.save
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome to Roomies!"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [
      :name,
      :email,
      :password,
      :password_confirmation
    ])
  end
end
