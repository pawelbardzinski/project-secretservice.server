class V1::ProductsController < ApiApplicationController
  before_action :authenticate_read, only:[:show,:index]
  before_action :authenticate_readwrite, only:[:new,:create,:update,:destroy]
  before_action :set_product, only: [:show, :update, :destroy]


  swagger_controller :products, "Product Management"

  swagger_api :show do
    summary "Fetches a single Product item"
    param :path, :id, :integer, :required, "Product Id"
    param :path, :venue_id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :index do
    summary "Fetches all products"
    param :path, :venue_id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Product"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :path, :id, :integer, :required, "Product Id"
    param :body, :product,:Product,:required,'Product object {"product":{[product body on right]}}'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :new do
    summary "Returns a single blank product item"
    param :path, :venue_id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a product"
    param :path, :venue_id, :integer, :required, "Venue Id"
    param :path, :id, :integer, :required, "Product Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_model :Product do
    description "A Product object."
    property :id, :integer, :required, "Product Id"
    property :venue_id, :integer, :required, "Venue Id"
    property :price, :float, :requried, "Price"
    property :rating, :float, :required, "Rating"
  end


  # GET /v1/venue/1/products/new
  def new
    @product = Product.new
    @product.venue_id = params[:venue_id]
    render json:@product, status: :ok
  end

  # GET /v1/venue/1/products/1
  def show
    render json: @product, status: 200
  end

  # GET /v1/venue/1/products
  def index
    products = Product.where(venue_id:params[:venue_id],archived:false)
    render json: products, status: 200
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      render json:@product, status: :created
    else
      render json: format_errors(@product.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/venues/1/products/1
  # PATCH/PUT /v1/venues/1/products/1.json
  def update
    if @product.update(product_params)
      render json:@product, status: :ok
    else
      render json: format_errors(@product.errors), status: :unprocessable_entity
    end
  end

  def upload
    uploaded_file = params[:file]

    name =  params[:imageName] #uploaded_file.original_filename

    # create the file path
    path = File.join("public","images", name)
    # write the file
    File.open(path, "wb") { |f| f.write(uploaded_file.read) }

    head :no_content
  end

  # DELETE /v1/products/1
  # DELETE /v1products/1.json
  def destroy
    @product.archive
    head :no_content
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find_unarchived(params[:id])
    @product = nil if params[:venue_id] != @product.venue_id.to_s
  end

  def product_params
    params.require(:product).permit(:name, :price, :rating, :venue_id)
  end

  def authenticate_read
    authenticate
  end

  def authenticate_readwrite
    authenticate
    render_unauthorized  unless ((@current_user.role & User::ROLES[:venue_admin][:id]) > 0 and params[:venue_id].to_i == @current_user.venue_id)
  end
end
