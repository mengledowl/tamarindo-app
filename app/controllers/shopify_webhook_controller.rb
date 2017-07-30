class ShopifyWebhookController < ApplicationController
  # todo: might also need to move the actual logic out into a background job of some kind b/c we only have 5 sec
  # to respond with a 200 before Shopify marks it as failed and starts retrying. Don't want to risk LogOn being slow

  before_action :verify_webhook

  def order_created
    head 200 and return if OrderEvent.where(shopify_order_id: params[:id]).first.present?

    event = OrderEvent.create!(shopify_order_id: params[:id])

    ProcessOrderEventWorker.perform_async(event.id)

    # will raise an error if it fails for some reason which means we won't set processed: true which is what we want
    # Logon.send_order_details(params)
    #
    # event.update(processed: true)

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