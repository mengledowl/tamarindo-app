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

      client = Savon.client(wsdl: Rails.root.join('app', 'middleware', 'logon_wsdl.xml'), proxy: ENV['FIXIE_URL'])

      # todo: pass order details to logon
      [ 200, { 'Content-Type' => 'image/png' }, [ File.read(File.join(File.dirname(__FILE__), 'slp.png')) ] ]
    else
      Rails.logger.send(:info, "MIDDLEWARE FOR APP")
      @app.call(env)
    end
  end

end