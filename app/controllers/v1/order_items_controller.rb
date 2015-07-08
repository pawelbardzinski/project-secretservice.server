include ActiveModel::Serialization
class V1::OrderItemsController < ApiApplicationController
  before_action :authenticate

  swagger_controller :orders, "Order Management"


  swagger_api :index do
    summary "Fetches orders"
    # param :query, :search_term, :string, :optional, "search_term"
    # param :query, :order, :string, :optional, "Order (name,distance)"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  # GET /venues.json
  def index
    return render json: {}, status: 401 if @current_user.role != 8
    subject = OrderItem.includes({order: [:venue, :user]}, :product)
    @order_items = params[:all] && params[:all] == 'true' ? subject.all : subject.all.limit(1000)
    render json: @order_items, root: "data", meta: {size: subject.all.size }, each_serializer: OrderItemsSerializer, status: 200
  end

end
