require 'twilio-ruby'

class SMSSender

  def initialize
  end

  def reset_password_sms(user)
    url = APP_CONFIG['password_reset_url']
    account_sid = APP_CONFIG["sms_account_sid"]
    auth_token = APP_CONFIG["sms_auth_token"]
    sms_from = APP_CONFIG["sms_from"]


    password_reset_url = "#{url}?" + user.password_reset_token
    client = Twilio::REST::Client.new account_sid, auth_token

    client.account.messages.create({
                                        :from => sms_from,
                                        :to => user.mobile,
                                        :body => 'Client the following link to reset your password. ' + password_reset_url,
                                    })
  end
end
