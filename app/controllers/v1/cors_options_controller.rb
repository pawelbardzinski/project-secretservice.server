class V1::CorsOptionsController < ApplicationController
  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end
end
