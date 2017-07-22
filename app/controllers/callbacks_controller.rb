class CallbacksController < ApplicationController
  def update_variant_quantity
    variant = ShopifyAPI::Variant.find(params[:id])
    variant.inventory_quantity = params[:quantity]

    if variant.save
      head 200
    else
      head 500
    end
  end
end