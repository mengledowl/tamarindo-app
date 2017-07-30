module Logon
  class << self
    def get_ats(style)
      response = client.call(:ats, message: { style: style })

      Logon::Ats.new(data: response.body, style: style)
    end

    def send_order_details(details)
      # todo: make this actually send details - currently getting errors from LogOn

      client.call(:putorder, message: prepare_order_details(details))
    end

    def prepare_order_details(details)
      items = details[:line_items].map do |line_item|
        Variant.find_by(shopify_variant_id: line_item[:variant_id]).to_putorder_format(line_item[:quantity])
      end

      header = {
          shiptocontact: details.dig(:shipping_address, :name),
          shiptoaddress1: details.dig(:shipping_address, :address1),
          shiptoaddress2: details.dig(:shipping_address, :address2),
          shiptocity: details.dig(:shipping_address, :city),
          shiptostate: details.dig(:shipping_address, :province_code),
          shiptozip: details.dig(:shipping_address, :zip),
          shiptocountry: details.dig(:shipping_address, :country_code),
          shiptophone: details.dig(:shipping_address, :phone),
          shiptoemail: details.dig(:customer, :email),
          shipvia: details.dig(:shipping_lines)&.first&.dig(:code)
      }

      {
          header: header,
          detail: {
              item: items
          }
      }
    end

    def client
      @client ||= Savon.client(wsdl: Rails.root.join('vendor', 'logon', 'logon_wsdl.xml'),
                               proxy: ENV['FIXIE_URL'], endpoint: "http://asp.logonsystems.com:8110/b2c", log: true,
                               pretty_print_xml: true, namespace: "http://asp.logonsystems.com/b2c")
    end
  end
end