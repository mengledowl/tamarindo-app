class ProcessOrderCancellationWorker
  include Sidekiq::Worker

  def perform(order_event_id)
    event = OrderEvent.find(order_event_id)

    response = Logon.cancel_order(event.logon_ordnum)

    response_body = response.hash.dig(:envelope, :body, :cancelorder_response, :ret)

    logger.info "Cancelled order with OrderEvent id #{event.id} and got response from LogOn: #{response.hash}"
    logger.error "Cancelled order with OrderEvent id #{event.id} and got ret: #{response_body}: #{response}" if response_body != '0'

    event.update(cancelled: true)
  end
end