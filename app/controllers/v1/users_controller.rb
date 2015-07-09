class V1::UsersController < ApiApplicationController
  before_action :set_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :authenticate, except: [:create, :new, :get_by_token]
  before_action :can_execute, except: [:index, :create, :new, :get_by_token]

  swagger_controller :users, 'User Management'

  swagger_api :show do
    summary 'Fetches a single User item'
    param :path, :id, :integer, :required, 'User Id'
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :index do
    summary 'Fetches all users'
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :create do
    summary 'Creates a new User'
    param :body, :user, :User, :required, 'User object {"user":{[user body on right]}}'
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary 'Updates an existing User'
    param :path, :id, :integer, :required, 'User Id'
    param :body, :user, :User, :required, 'User object {"user":{[user body on right]}}'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :new do
    summary 'Returns a single blank user item'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary 'Deletes a user'
    param :path, :id, :integer, :required, 'User Id'
    response :unauthorized
    response :not_acceptable
  end

  swagger_model :User do
    description 'A User object.'
    property :id, :integer, :required, 'User Id'
    property :firstname, :string, :requried, 'First Name'
    property :lastname, :string, :optional, 'Last Name'
    property :email, :string, :required, 'Email'
    property :mobile, :string, :required, 'Mobile'
    property :role, :int, :required, 'Role (Customer:1,Waiter:2,VenueAdmin:4,Admin:8)'
    property :password, :string, :optional, 'Password'
  end

  # GET /v1/users/1
  def show
    render json: @user, status: 200
  end

  # GET /v1/users/get_by_token/1
  def get_by_token
    user = User.where('password_reset_token = ? and password_expires_after > ?', params[:token],  DateTime.current).first
    unless user.nil?
      render json: user, status: 200
      return
    end
    head :not_found
  end

  # GET /v1/users/1
  def index
    return render json: [@current_user] unless [4, 8].include? @current_user.role
    users = if @current_user.role == 4
              @current_user.venue_id ? User.where(venue_id: @current_user.venue_id, archived: false) : []
            else
              User.where(archived: false)
            end
    render json: users, status: 200
  end

  # GET /v1/users/new
  def new
    @user = User.new
    render json: @user, status: :ok
  end

  # POST /v1/users
  def create
    @user = User.new(user_params)
    # User class has logic to default role. Prevent new users from setting a higher role
    authenticate if request.headers['x-auth-token']
    @user.role = nil if @current_user.nil?
    @user.password = params[:password] if params[:password]
    if @user.save
      render json: @user, status: :created
    else
      render json: format_errors(@user.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/users/1
  def update
    @user.password = params[:password] if params[:password]
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: format_errors(@user.errors), status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    if @user.archive
      head :no_content
    else
      render json: format_errors(@user.errors), status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_unarchived(params[:id]) if params[:id]
  end

  def can_execute
    # Valid for noncustomers or if current user is performing actions on their own record.
    render_unauthorized unless (@current_user.role == User::ROLES[:admin][:id]) ||
                               (@user && @user.id == @current_user.id) ||
                               (@current_user.role == User::ROLES[:venue_admin][:id] && (@user.nil? || @user.venue_id == @current_user.venue_id)) ||
                               (params[:action] == :show && @user && @user.id == @current_user.id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :mobile, :role, :password, :venue_id)
  end
end
