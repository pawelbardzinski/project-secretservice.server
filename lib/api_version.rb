class ApiVersion
  def initialize(version, default=false)
    @version, @default = version, default
  end

  def matches?(request)
    @default     || check_headers(request.headers)
  end

  def check_headers(headers)
    appId = headers['x-application-id']
    appId && appId.include?("com.secret-service.#{@version}")
  end
end