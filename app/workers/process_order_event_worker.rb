class ProcessOrderEventWorker
  include Sidekiq::Worker

  def perform(order_event_id)
    event = OrderEvent.find(order_event_id)
    shopify_order = ShopifyAPI::Order.find(event.shopify_order_id)
    attributes = JSON.parse(shopify_order.to_json).with_indifferent_access

    Logon.send_order_details(attributes)
    event.update(processed: true)
  end
end