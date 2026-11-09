
class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Reset your Roomies password"
    )
  end
end
