module Logon
  class << self
    def get_ats(style)
      response = client.call(:ats, message: { style: style })

      Logon::Ats.new(data: response.body, style: style)
    end

    def send_order_details(details)
      client.call(:putorder, xml: putorder_xml(details))
    end

    def client
      @client ||= Savon.client(wsdl: Rails.root.join('vendor', 'logon', 'logon_wsdl.xml'),
                               proxy: ENV['FIXIE_URL'], endpoint: "http://asp.logonsystems.com:8110/b2c", log: true,
                               pretty_print_xml: true, namespace: "http://asp.logonsystems.com/b2c")
    end

    def putorder_xml(details)
      <<-XML
        <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:fjs="http://asp.logonsystems.com/b2c" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ins0="http://asp.logonsystems.com/types/">
          <env:Body>
            <fjs:putorder>
              <rec>
                <header>
                  <ponum>#{details.dig(:id)}</ponum>
                  <sotype>EC</sotype>
                  <orddate>#{Date.parse(details.dig(:created_at)).strftime('%Y-%m-%d')}</orddate>
                  <startship>#{Time.now.strftime('%Y-%m-%d')}</startship>
                  <cancel>#{30.days.from_now.strftime('%Y-%m-%d')}</cancel>
                  <billtoccode>265346</billtoccode>
                  <shiptocext></shiptocext>
                  <shiptocontact>#{details.dig(:shipping_address, :name)}</shiptocontact>
                  <shiptocompany>#{details.dig(:shipping_address, :copmany) || details.dig(:shipping_address, :first_name)}</shiptocompany>
                  <shiptoaddress1>#{details.dig(:shipping_address, :address1)}</shiptoaddress1>
                  <shiptoaddress2>#{details.dig(:shipping_address, :address2)}</shiptoaddress2>
                  <shiptocity>#{details.dig(:shipping_address, :city)}</shiptocity>
                  <shiptostate>#{details.dig(:shipping_address, :province_code)}</shiptostate>
                  <shiptozip>#{details.dig(:shipping_address, :zip)}</shiptozip>
                  <shiptocountry>#{details.dig(:shipping_address, :country_code)}</shiptocountry>
                  <shiptophone>#{details.dig(:shipping_address, :phone)}</shiptophone>
                  <shiptoemail>#{details.dig(:customer, :email)}</shiptoemail>
                  <shipvia>UPS GROUND</shipvia>
                  <freight xsi:nil="true"/>
                  <tax>#{details.dig(:total_tax)}</tax>
                  <note></note>
                  <msg></msg>
                  <crefnum>?</crefnum>
                  <currency>#{details.dig(:currency)}</currency>
                </header>
                <detail SOAP-ENC:arrayType="fjsd:putorder_rec_in_detail[#{items_xml(details).size}]">
                  #{items_xml(details).join('')}
                </detail>
              </rec>
            </fjs:putorder>
          </env:Body>
        </env:Envelope>
      XML
    end

    def items_xml(details)
      items = details[:line_items].map do |line_item|
        Variant.find_by(shopify_variant_id: line_item[:variant_id]).to_putorder_format(line_item[:quantity], line_item[:price])
      end

      items.map do |item|
        <<-XML
          <item>
            <style>#{item[:style]}</style>
            <col>#{item[:col]}</col>
            <dm>#{item[:dm]}</dm>
            <size>#{item[:size]}</size>
            <quantity>#{item[:quantity]}</quantity>
            <unitprice>#{item[:unitprice]}</unitprice>
            <reference></reference>
          </item>
        XML
      end
    end
  end
end