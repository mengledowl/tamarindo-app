class LogonCallbacksController < ApplicationController
  http_basic_authenticate_with name: ENV['LOGON_AUTH_USERNAME'], password: ENV['LOGON_AUTH_PASSWORD']

  def update_variant_quantity
    variant = Variant.where(logon_style: params[:style], logon_col: params[:col], logon_dm: params[:dm], logon_size: params[:size]).first

    head 404 and return unless variant

    UpdateVariantQuantityWorker.perform_async(variant.id)

    head 200
  end
end