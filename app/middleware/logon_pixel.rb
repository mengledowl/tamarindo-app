class LogonPixel
  def initialize(app)
    @app = app
  end

  def call(env)
    dup._call(env)
  end

  def _call(env)
    if env.fetch('PATH_INFO') =~ /^\/slp\/(.+)\.png/
      Rails.logger.info "MIDDLEWARE FOR PNG"

      details = Base64.decode64(Regexp.last_match[1])
      details_hash = Rack::Utils.parse_nested_query(details)

      Rails.logger.info details_hash

      Order::Logon.send_order_details(details_hash)
      [ 200, { 'Content-Type' => 'image/png' }, [ File.read(File.join(File.dirname(__FILE__), 'slp.png')) ] ]
    else
      Rails.logger.send(:info, "MIDDLEWARE FOR APP")
      @app.call(env)
    end
  end
end