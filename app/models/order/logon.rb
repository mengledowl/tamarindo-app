module Order
  class Logon
    def self.get_ats_quantity(ats_style)
      # these are assumptions for now until we can see the actual data as it comes in
      # response = client.call(:ats, { style: ats_style })
      #
      # response.body['rec'].first['item']
    end

    def self.send_order_details(details)
      # todo: make this actually send details
      # sounds like we will likely be using putorder to do this?
    end

    private

    def self.client
      Savon.client(wsdl: Rails.root.join('app', 'middleware', 'logon_wsdl.xml'), proxy: ENV['FIXIE_URL'])
    end
  end
end