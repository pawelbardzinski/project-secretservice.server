class V1::OrdersController < ApiApplicationController
  before_action :authenticate
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authorize_update,only: [:show, :edit, :update, :destroy]
  before_action :authorize_index,only: [:index]


  swagger_controller :orders, "Order Management"

  swagger_api :show do
    summary "Fetches a single order"
    param :path, :id, :integer, :required, "Order Id"
    param :path, :venue_id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :index do
    summary "Fetches all orders by venue id"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :query, :user_id, :integer, :optional, "User Id"
    param :query, :venue_user_id, :integer, :optional,"Venue User Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :create do
    summary "Creates a new Order"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :body, :order,:Order,:required,'Order object {"order":{[order body on right]}}'
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Order"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :path, :id, :integer, :required, "Order Id"
    param :body, :order,:Order,:required,'Order object {"order":{[order body on right]}}'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :new do
    summary "Returns a single blank user item"
    param :path, :venue_id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a order"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :path, :id, :integer, :required, "Order Id"
    param :query, :cancel_reason, :string, :optional, "Cancel reason"
    response :unauthorized
    response :not_acceptable
  end

  swagger_model :Order do
    description "A Order object."
    property :id, :integer, :required, "Order Id"
    property :user_id, :integer, :required, "User Id"
    property :venue_id, :integer, :required, "Venue Id"
    property :payment_option_id, :integer, :optional, "Payment Option Id"
    property :location, :string, :required, "Location"
    property :venue_user_id, :integer, :required, "Venue user Id (wait staff assigned)"
    property :cancel_reason, :string, :required, "Cancel reason"
    property :order_items,:array,:required,"Order Items"
  end

  swagger_model :Order_Item do
    description "A Order Item object."
    property :id, :integer, :required, "Order Item Id"
    property :order_id, :integer, :required, "Order Id"
    property :product_id, :integer, :required, "Product Id"
    property :quantity, :integer, :required, "Quantity Id"
  end

  # GET /v1/venue/1/orders/1
  def show
    venue_id = params[:venue_id]
    order = Order.includes(:user).includes(:order_items).find(params[:id])
    if (venue_id and venue_id == order.venue_id.to_s)
      render json: order,include: [:order_items => {:methods => :product_name}], status: 200
    else
      head :not_found
    end
  end

  # GET /v1/venue/1/orders
  def index
    user_id = params[:user_id]
    venue_id = params[:venue_id]
    venue_user_id = params[:venue_user_id]
    orders = Order.where(venue_id:params[:venue_id])
    if @current_user.is_in_role(User::ROLES[:customer][:id])
      orders = orders.where(user_id:@current_user.id)
    end
    if user_id
      orders = orders.where(user_id:params[:user_id])
    end
    if venue_user_id
      orders = orders.where(venue_user_id:params[:venue_user_id])
    end
    render json: orders, status: 200
  end

  # GET /v1/venue/1/orders/new
  def new
    @order = Order.new
    @order.venue_id = params[:venue_id]
    @order.order_items << OrderItem.new
    render json:@order,include: :order_items, status: :ok
  end

  # POST /v1/venue/1/orders
  def create
    @order = Order.new(order_params)
    @order.order_status = Order::STATUSES[:submitted][:id]
    set_prices @order
    set_payment @order

    if @order.save
      render json:@order,include: [:order_items => {:methods => :product_name}], status: :created
    else
      render json: format_errors(@order.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/venue/1/orders/1
  def update
    @order.assign_attributes(order_params_for_update)

    if(@order.order_status == Order::STATUSES[:submitted][:id])
      set_prices @order
      set_payment @order
    end

    if @order.save
      render json:@order,include: [:order_items => {:methods => :product_name}], status: :ok
    else
      render json: format_errors(@order.errors), status: :unprocessable_entity
    end
  end

  # DELETE /v1/venue/1/orders/1
  def destroy
    if @order.order_status != Order::STATUSES[:completed][:id]
      @order.cancel_reason = params[:cancel_reason]

      if @order.cancel
        head :no_content
      else
        render json: format_errors(@order.errors), status: :unprocessable_entity
      end
    else
      message= ['Cannot cancel an order that has been delivered.']
      render json: message, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  def set_prices(order)
    order.order_items.each do |order_item|
      if order_item.product_id
        product = Product.find(order_item.product_id)
        order_item.price = product.price
      end
    end
  end

  def set_payment(order)
    if params[:order][:payment_option_id] and  params[:order][:payment_option_id].to_i != 0
      payment_option = PaymentOption.find(params[:order][:payment_option_id].to_i)
      if payment_option and payment_option.user_id == order.user_id
        order.last_4 = payment_option.last_4
        order.credit_card_brand = payment_option.credit_card_brand
        order.payment_identifier = payment_option.payment_identifier
        order.payment_type = payment_option.payment_type
      end
    elsif  params[:order][:payment_option_id] == "0"
      order.last_4 = nil
      order.credit_card_brand = nil
      order.payment_identifier = nil
      order.payment_type = nil
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:location,:user_id, :venue_id,{order_items_attributes:[:product_id, :quantity] })
  end

  def order_params_for_update
    params.require(:order).permit(:location,:order_status,:venue_user_id,{order_items_attributes:[:product_id, :quantity] })
  end

  def order_item_params(order_item)
    order_item.permit(:product_id, :quantity)
  end

  def authorize_update
    authorize_user_can_update @order.user_id.to_s unless @current_user.is_in_role( User::ROLES[:waiter][:id])
  end


  def authorize_index
    render_unauthorized unless @current_user.is_in_role( User::ROLES[:customer][:id])  or
        (@current_user.venue_id and @current_user.venue_id == params[:venue_id].to_i)
  end
end
