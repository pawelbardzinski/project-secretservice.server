require 'active_support/all'
require 'twilio-ruby'
class ApiApplicationController <  ActionController::Base
  abstract!
  protect_from_forgery with: :null_session
  before_action :check_application_id
  after_filter :cors_set_headers

  class << self
    Swagger::Docs::Generator::set_real_methods

    def inherited(subclass)
      super
      subclass.class_eval do |controller_class|
        setup_basic_api_documentation controller_class
      end
    end

    def current_user
      @current_user
    end

    private

    def setup_basic_api_documentation controller_class
      [:index, :show, :create, :update, :destroy,:new].each do |api_action|
        swagger_api api_action do
          param :header, 'x-auth-token', :string, :required, 'Authentication token' unless (api_action == :create || api_action == :new) and ( controller_class.to_s =="V1::UsersController" || controller_class.to_s =="V1::SessionsController")
        end
      end
    end
  end

  def cors_set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept,X-Requested-With,x-application-id,x-auth-token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def format_errors(errors)
    formatted_messages = []
    errors.messages.each do |hash, messages|
      hashName = format_name(hash.to_s)
      messages.each do |message|
        formatted_messages << "#{hashName} #{message}"
      end
    end
    formatted_messages
  end

  def check_application_id
    render_unauthorized unless request.headers['x-application-id'].to_s.start_with?('com.secret-service')
  end

  def authenticate
      if request.headers['x-application-id'] and request.headers['x-application-id'].to_s.start_with?('com.secret-service')
      authenticate_token || render_unauthorized
    else
      render_unauthorized
    end
  end

  def authenticate_token
    authToken = request.headers['x-auth-token']
    if authToken
      @current_user = User.find_by(auth_token: authToken)
      if @current_user == nil ||
        @current_user.archived ||
        @current_user.token_expiration < Time.now
        return nil
      end
      if @current_user.venue_id
        venue = Venue.find(@current_user.venue_id)
        return nil if venue.archived
      end
      @current_user
    else
      return nil
    end

  end

  def authenticate_basic_auth
    authenticate_with_http_basic do |username, password|
      User.authenticate(username, password)
    end
  end


  def render_unauthorized(realm=nil)
    if realm
      self.headers['WWW-Authenticate'] = %(Token realm="#{realm.gsub(/"/, "")}")
    end
    render json: {message:"Bad credentials"}, status: :unauthorized
  end

  def authorize_user_can_update(user_id)
    render_unauthorized unless @current_user.id.to_s == user_id.to_s
  end

  private
  def format_name(name)
    if name == :firstname.to_s
      "First name"
    elsif name==:lastname.to_s
      "Last name"
    elsif name==:last_4.to_s
      "Credit card or Membership Id"
    elsif name==:address_line_1.to_s
      "Address"
    elsif name==:password_digest.to_s
      "Password"
    else
      name.titleize
    end
  end

end