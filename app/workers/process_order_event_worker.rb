class ProcessOrderEventWorker
  include Sidekiq::Worker

  def perform(order_event_id)
    event = OrderEvent.find(order_event_id)

    unless event.processed
      shopify_order = ShopifyAPI::Order.find(event.shopify_order_id)
      attributes = JSON.parse(shopify_order.to_json).with_indifferent_access

      response = Logon.send_order_details(attributes)

      response_body = response.hash.dig(:envelope, :body, :putorder_response, :rec)

      logger.error "No response body found in response: #{response}" unless response_body.present?
      logger.error "Error encountered when sending order details to logon: #{response_body&.dig(:errormsg)}" if response_body&.dig(:errormsg)

      event.update(processed: true, logon_ordnum: response_body&.dig(:ordnum).to_i)
    end
  end
end