module Logon
  class << self
    def get_ats(style)
      response = client.call(:ats, message: { style: style })

      Logon::Ats.new(data: response.body, style: style)
    end

    def send_order_details(details)
      # todo: make this actually send details
      # sounds like we will likely be using putorder to do this?
    end

    def client
      @client ||= Savon.client(wsdl: Rails.root.join('app', 'middleware', 'logon_wsdl.xml'),
                               proxy: ENV['FIXIE_URL'], endpoint: "http://asp.logonsystems.com:8110/b2c", log: true,
                               pretty_print_xml: true, namespace: "http://asp.logonsystems.com/b2c")
    end
  end
end