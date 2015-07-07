class V1::PaymentOptionsController < ApiApplicationController
  before_action :authenticate
  before_action :set_payment_option, only: [:show, :edit, :update, :destroy]
  before_action :authorize_update,only: [:show, :edit, :update, :destroy]


  swagger_controller :payment_options, "Payment Options Management"

  swagger_api :show do
    summary "Fetches a single payment options"
    param :path, :id, :integer, :required, "Payment Option Id"
    param :path, :user_id, :integer, :required, "User Id"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :index do
    summary "Fetches all payment options by user id"
    param :path, :user_id, :integer, :required, "User Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :create do
    summary "Creates a new payment option"
    param :path, :user_id, :integer, :required, "User Id"
    param :body, :payment_option,:payment_option,:required,'Payment option object {"payment_option":{[payment_option body on right]}}'
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing payment option"
    param :path, :user_id, :integer, :required, "User Id"
    param :path, :id, :integer, :required, "Payment Option Id"
    param :body, :payment_option,:payment_option,:required,'Payment option object {"payment_option":{[payment_option body on right]}}'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :new do
    summary "Returns a single blank payment option item"
    param :path, :user_id, :integer, :required, "User Id"
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a payment option"
    param :path, :user_id, :integer, :required, "User Id"
    param :path, :id, :integer, :required, "Payment Option Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_model :payment_option do
    description "A payment_options object."
    property :id, :integer, :required, "Payment Option Id"
    property :user_id, :integer, :required, "User Id"
    property :payment_identifier, :string, :required, "Payment identifier"
    property :payment_type, :string, :required, "Payment type (credit card=1,membership id=2)"
    property :credit_card_brand,:string,:required,"Credit card brand"
  end


  # GET /v1/venue/1/payment_options/1
  def show
    user_id= params[:user_id]
    payment_option = PaymentOption.find(params[:id])
    if (user_id and user_id == payment_option.user_id.to_s)
      render json: payment_option, status: 200
    else
      head :not_found
    end
  end

  # GET /v1/venue/1/payment_options
  def index
    user_id = params[:user_id]
    payment_options = PaymentOption.where(user_id:params[:user_id])
    render json: payment_options, status: 200
  end

  # GET /v1/venue/1/payment_options/new
  def new
    @payment_option = PaymentOption.new
    @payment_option.user_id = params[:user_id]
    payment_option = @payment_option.as_json
    payment_option[:credit_card]=nil
    render json:payment_option, status: :ok
  end

  # POST /v1/venue/1/payment_options
  def create
    @payment_options = PaymentOption.new(payment_options_params)
    @payment_options.set_last_4(params[:payment_option][:payment_identifier]) if params[:payment_option][:payment_identifier]

    if @payment_options.save
      render json:@payment_options, status: :created
    else
      render json: format_errors(@payment_options.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/user/1/payment_options/1
  def update
    @payment_option.assign_attributes(payment_options_params)
    @payment_option.set_last_4(params[:payment_option][:payment_identifier]) if params[:payment_option][:payment_identifier]

    if @payment_option.save
      render json:@payment_option, status: :ok
    else
      render json: format_errors(@payment_option.errors), status: :unprocessable_entity
    end
  end

  # DELETE /v1/venue/1/payment_options/1
  def destroy
    @payment_option.destroy
    head :no_content
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_payment_option
    @payment_option = PaymentOption.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_options_params
    params.require(:payment_option).permit(:user_id, :credit_card_brand,:payment_type,:venue_id,:payment_identifier)
  end

  def authorize_update
    authorize_user_can_update( params[:user_id] ) || authorize_user_can_update( @payment_option.user_id ) if @payment_option
  end

end
