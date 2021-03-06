class ShopifyWebhookController < ApplicationController
  before_action :verify_webhook

  def order_created
    unless OrderEvent.where(shopify_order_id: params[:id]).first.present?
      event = OrderEvent.create!(shopify_order_id: params[:id])

      ProcessOrderEventWorker.perform_async(event.id)
    end

    head 200
  end

  def order_cancelled
    order_event = OrderEvent.find_by(shopify_order_id: params[:id])

    ProcessOrderCancellationWorker.perform_async(order_event.id)

    head 200
  end

  private

  def verify_webhook
    digest  = OpenSSL::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_SHARED_SECRET'], request.body.read)).strip
    verified = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, request.headers['HTTP_X_SHOPIFY_HMAC_SHA256'])

    head 401 unless verified
  end
end