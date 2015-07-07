class UserMailer < ActionMailer::Base
  default from: APP_CONFIG["mail_from"]

  def reset_password_email(user)
    @user = user
    url = APP_CONFIG['password_reset_url']

    @password_reset_url = "#{url}" + @user.password_reset_token
    mail(:to => user.email, :subject => 'Password Reset Instructions.')
  end
end
