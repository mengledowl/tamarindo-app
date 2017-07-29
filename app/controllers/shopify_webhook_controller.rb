class ShopifyWebhookController < ApplicationController
  # todo: might want to store the order id so we know we've already gotten this create and don't do it multiple times if
  # shopify sends it to us more than once

  # todo: might also need to move the actual logic out into a background job of some kind b/c we only have 5 sec
  # to respond with a 200 before Shopify marks it as failed and starts retrying. Don't want to risk LogOn being slow

  before_action :verify_webhook

  def order_created
    items = Logon.send_order_details(params)

    items
  end

  private

  def verify_webhook
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV['SHOPIFY_SHARED_SECRET'], request.body.read)).strip
    verified = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, request.headers['HTTP_X_SHOPIFY_HMAC_SHA256'])

    head 401 unless verified
  end
end