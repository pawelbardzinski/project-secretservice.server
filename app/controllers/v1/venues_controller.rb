class V1::VenuesController < ApiApplicationController
  before_action :set_venue, only: [:show, :edit, :update,:destroy]
  before_action :authenticate_read, only:[:show,:index]
  before_action :authenticate_readwrite, only:[:new,:create,:update,:destroy]
  swagger_controller :venues, "Venue Management"


  swagger_api :index do
    summary "Fetches venues"
    param :query, :search_term, :string, :optional, "search_term"
    param :query, :latitude, :float, :optional, "Latitude"
    param :query, :longitude, :float, :optional, "Longitude"
    param :query, :distance, :integer, :optional, "Distance"
    param :query, :order, :string, :optional, "Order (name,distance)"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :show do
    summary "Fetches a single Venue item"
    param :path, :id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new Venue"
    param :body, :venue,:Venue,:required,'Venue object {"venue":{[venue body on right]}}'
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Venue"
    param :path, :id, :integer, :required, "Venue Id"
    param :body, :venue,:Venue,:required,'Venue object {"venue":{[venue body on right]}}'
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :new do
    summary "Returns a single blank venue item"
    response :unauthorized
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a venue"
    param :path, :id, :integer, :required, "Venue Id"
    response :unauthorized
    response :not_acceptable
  end

  swagger_model :Venue do
    description "A Venue object."
    property :id, :integer, :required, "Venue Id"
    property :name, :string, :required, "Name"
    property :address_line_1, :string, :required, "Address"
    property :city, :string, :required, "City"
    property :state, :string, :required, "State"
    property :zip_code, :string, :required, "Zip code)"
    property :country, :string, :required, "Country"
    property :allow_membership_payment, :bool, :required, "Allow membership payment"
    property :allow_credit_card_payment, :bool, :required, "Allow credit card payment"
    property :allow_cash_payment, :bool, :required, "Allow cash payment"
  end
  # GET /venues.json
  def index
    @venues = Venue.where(archived:false)
    if lat = params[:latitude] and long = params[:longitude]
      @venues = @venues.near([lat, long], params[:distance] || 5)
    end

    if search_term = params[:search_term]
      #search_terms = search_term.gsub(/\s+/m, ' ').strip.split(" ")
      sql = ""
      search_terms = search_term.split(" ")
      search_terms.each do |term|
        #@venues = @venues.where("name like ?", '%' + term + '%')
        sql += ' or ' unless sql.length == 0
        sql += " name like '%#{term}%' or city like '%#{term}%' "

      end
      @venues = @venues.where( sql )
    end

    render json: @venues, status: 200
  end

  # GET /v1/venues/1.json
  def show
    render json: @venue, status: 200
  end

  # GET /v1/venues/new
  def new
    @venue = Venue.new
    render json:@venue, status: :ok
  end

  # POST /v1/venues/1
  def create
    @venue = Venue.new(venue_params)

    if @venue.save
      render json:@venue, status: :created
    else
      render json: format_errors(@venue.errors), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/venues/1
  # PATCH/PUT /v1/venues/1.json
  def update
    if @venue.update(venue_params)
      render json:@venue, status: :ok
    else
      render json: format_errors(@venue.errors), status: :unprocessable_entity
    end
  end

  def destroy
    @venue.archive
    head :no_content
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_venue
    @venue = Venue.find_unarchived(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def venue_params
    params.require(:venue).permit(:name, :latitude, :longitude, :address_line_1, :address_line_2, :city, :state, :zip_code, :country,:allow_membership_payment,:allow_credit_card_payment,:allow_cash_payment)
  end


  def authenticate_read
    authenticate
  end

  def authenticate_readwrite
    authenticate
    render_unauthorized  unless ((@current_user.role & User::ROLES[:admin][:id]) > 0 ) or
                                  ((@current_user.role & User::ROLES[:venue_admin][:id]) > 0 and @venue and @venue.id == @current_user.venue_id )
  end
end
