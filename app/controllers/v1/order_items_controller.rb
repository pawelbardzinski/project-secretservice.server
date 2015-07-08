include ActiveModel::Serialization
class V1::OrderItemsController < ApiApplicationController
  before_action :authenticate

  swagger_controller :expandables, "Expandable Management"


  swagger_api :index do
    summary "Fetches expandables"
    param :query, :search_term, :string, :optional, "search_term"
    param :query, :order, :string, :optional, "Order (name,distance)"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  # GET /venues.json
  def index
    return render json: {}, status: 401 if @current_user.role != 8
    @order_items = OrderItem.includes(order: :venue).all
    render json: @order_items, root: false, each_serializer: OrderItemsSerializer, status: 200
  end

end
