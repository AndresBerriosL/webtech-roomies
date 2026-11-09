
class ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_user

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to edit_profile_path,
                  notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(
      :name,
      :contact,
      :bio
    )
  end
end
