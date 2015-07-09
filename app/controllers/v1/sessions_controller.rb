require 'active_support/all'
require 'sms_sender.rb'

class V1::SessionsController < ApiApplicationController
  before_action :authenticate, only: :destroy

  swagger_controller :sessions, "Session Management"

  swagger_api :create do
    summary "Login"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :string, :required, "Password"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Logout"
    param :path, :id, :integer, :required, "User Id"
    response :no_content
    response :unauthorized
  end

  swagger_api :passwordreset do
    summary "Password reset"
    param :form, :email_or_mobile, :string, :required, "Email or mobile"
    response :no_content
    response :unauthorized
  end

  # POST /sessions.json
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      if user.venue_id
        venue = Venue.find(user.venue_id)
        return render_unauthorized if venue.archived
      end
      user.token_expiration = DateTime.current.advance(months:1)
      user.save
      render json:user
    else
      render_unauthorized
    end
  end

  # POST /sessions.json
  def destroy
    user = authenticate_token
    if user and user.id.to_s == params[:id]
      user.clear_auth_token
      user.save
      head :no_content
    else
      render_unauthorized
    end
  end


  # POST /sessions.json
  def password_reset
    email_or_mobile = params[:email_or_mobile]
    if email_or_mobile and email_or_mobile.include? '@'
      user = User.find_by_email(email_or_mobile)
      send_email = true
    else
      mobile = User.format_mobile(email_or_mobile)
      user = User.find_by_mobile(mobile)
      send_email = false
    end

    if user
      user.password_reset_token = SecureRandom.urlsafe_base64
      user.password_expires_after = 24.hours.from_now
      user.save
      if send_email
        UserMailer.reset_password_email(user).deliver
      else
        SMSSender.new.reset_password_sms(user)
      end
      head :no_content
    else
      head :not_found
    end
  end

  def password_update
    token = params[:token]
    @user = User.find_by_password_reset_token(token)

    if @user.nil? or @user.email != params[:email]
      return head :not_found
    else
      @user.password = params[:password]
      if(@user.save)
        return head :ok
      else
        render json: format_errors(@user.errors), status: :unprocessable_entity
      end
    end
  end
end
