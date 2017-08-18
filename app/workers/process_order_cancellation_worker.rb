class ProcessOrderCancellationWorker
  include Sidekiq::Worker

  def perform(order_event_id)
    event = OrderEvent.find(order_event_id)

    unless event.cancelled
      response = Logon.cancel_order(event.logon_ordnum)

      logger.info "Cancelled order with OrderEvent id #{event.id} and got response from LogOn: #{response.hash}"

      event.update(cancelled: true)
    end
  end
end