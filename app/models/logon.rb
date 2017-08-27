module Logon
  class << self
    def get_ats(style:, col:, dm:, size:)
      response = client.call(:ats, message: {
          style: style,
          col: col,
          dm: dm,
          size: size
      })

      Logon::Ats.new(data: response.body, style: style)
    end

    def send_order_details(details)
      client.call(:putorder, xml: putorder_xml(details))
    end

    def cancel_order(ordnum)
      client.call(:cancelorder, message: { ordnum: ordnum })
    end

    def client
      @client ||= Savon.client(wsdl: Rails.root.join('vendor', 'logon', 'logon_wsdl.xml'),
                               proxy: ENV['FIXIE_URL'], endpoint: ENV['LOGON_ENDPOINT'], log: true,
                               pretty_print_xml: true, namespace: "http://asp.logonsystems.com/b2c")
    end

    def putorder_xml(details)
      <<-XML
        <SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
                   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
                   xmlns:ns1313="http://asp.logonsystems.com/b2c" xmlns:fjsd="http://asp.logonsystems.com/types/">
          <SOAP-ENV:Body>
            <ns1313:putorder xmlns:ns1313="http://asp.logonsystems.com/b2c">
              <rec xsi:type="fjsd:putorder_rec_in">
                <header xmlns="" xsi:type="fjsd:putorder_rec_in_header">
                  <ponum xmlns="" xsi:type="fjsd:putorder_rec_in_header_ponum_FGLString">#{details.dig(:id)}</ponum>
                  <sotype xmlns="" xsi:type="fjsd:putorder_rec_in_header_sotype_FGLString">EC</sotype>
                  <orddate xsi:type="xsd:date">#{Date.parse(details.dig(:created_at)).strftime('%Y-%m-%d')}</orddate>
                  <startship xsi:type="xsd:date">#{Time.now.strftime('%Y-%m-%d')}</startship>
                  <cancel xsi:type="xsd:date">#{30.days.from_now.strftime('%Y-%m-%d')}</cancel>
                  <billtoccode xmlns="" xsi:type="fjsd:putorder_rec_in_header_billtoccode_FGLString">265346</billtoccode>
                  <shiptocext xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptocext_FGLString"></shiptocext>
                  <shiptocontact xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptocontact_FGLString">#{details.dig(:shipping_address, :name)}</shiptocontact>
                  <shiptocompany xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptocompany_FGLString">#{details.dig(:shipping_address, :copmany) || details.dig(:shipping_address, :first_name)}</shiptocompany>
                  <shiptoaddress1 xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptoaddress1_FGLString">#{details.dig(:shipping_address, :address1)}
                  </shiptoaddress1>
                  <shiptoaddress2 xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptoaddress2_FGLString">#{details.dig(:shipping_address, :address2)}</shiptoaddress2>
                  <shiptocity xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptocity_FGLString">#{details.dig(:shipping_address, :city)}</shiptocity>
                  <shiptostate xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptostate_FGLString">#{details.dig(:shipping_address, :province_code)}</shiptostate>
                  <shiptozip xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptozip_FGLString">#{details.dig(:shipping_address, :zip)}</shiptozip>
                  <shiptocountry xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptocountry_FGLString">#{details.dig(:shipping_address, :country_code)}</shiptocountry>
                  <shiptophone xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptophone_FGLString">#{details.dig(:shipping_address, :phone)}</shiptophone>
                  <shiptoemail xmlns="" xsi:type="fjsd:putorder_rec_in_header_shiptoemail_FGLString">#{details.dig(:customer, :email)}
                  </shiptoemail>
                  <shipvia xmlns="" xsi:type="fjsd:putorder_rec_in_header_shipvia_FGLString">UPS GROUND</shipvia>
                  <freight xmlns="" xsi:type="fjsd:putorder_rec_in_header_freight_FGLDecimal">0</freight>
                  <tax xmlns="" xsi:type="fjsd:putorder_rec_in_header_tax_FGLDecimal">#{details.dig(:total_tax)}</tax>
                  <note xmlns="" xsi:type="fjsd:putorder_rec_in_header_note_FGLString">#{details.dig(:note)&.gsub("\r\n", ' ')&.gsub("\n", ' ')}</note>
                  <msg xmlns="" xsi:type="fjsd:putorder_rec_in_header_msg_FGLString"></msg>
                  <crefnum xmlns="" xsi:type="fjsd:putorder_rec_in_header_crefnum_FGLString">?</crefnum>
                  <currency xmlns="" xsi:type="fjsd:putorder_rec_in_header_currency_FGLString">#{details.dig(:currency)}</currency>
                </header>
                <detail xmlns="" xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="fjsd:putorder_rec_in_detail[#{items_xml(details).size}]">
                  #{items_xml(details).join('')}
                </detail>
              </rec>
            </ns1313:putorder>
          </SOAP-ENV:Body>
        </SOAP-ENV:Envelope>
      XML
    end

    def items_xml(details)
      items = details[:line_items].map do |line_item|
        Variant.find_by(shopify_variant_id: line_item[:variant_id]).to_putorder_format(line_item[:quantity], line_item[:price])
      end

      items.map do |item|
        <<-XML
          <item xsi:type="fjsd:putorder_rec_in_detail">
            <style xmlns="" xsi:type="fjsd:putorder_rec_in_detail_style_FGLString">#{item[:style]}</style>
            <col xmlns="" xsi:type="fjsd:putorder_rec_in_detail_col_FGLString">#{item[:col]}</col>
            <dm xmlns="" xsi:type="fjsd:putorder_rec_in_detail_dm_FGLString">#{item[:dm]}</dm>
            <size xmlns="" xsi:type="fjsd:putorder_rec_in_detail_size_FGLString">#{item[:size]}</size>
            <quantity xsi:type="xsd:int">#{item[:quantity]}</quantity>
            <unitprice xmlns="" xsi:type="fjsd:putorder_rec_in_detail_unitprice_FGLDecimal">#{item[:unitprice]}</unitprice>
            <reference xmlns="" xsi:type="fjsd:putorder_rec_in_detail_reference_FGLString"></reference>
          </item>
        XML
      end
    end
  end
end