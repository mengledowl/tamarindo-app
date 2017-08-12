module AuthHelper
  def http_login(user: ENV['LOGON_AUTH_USERNAME'], pw: ENV['LOGON_AUTH_PASSWORD'])
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end
end