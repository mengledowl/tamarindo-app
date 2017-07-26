class CallbacksController < ApplicationController
  def update_variant_quantity
    if Shopify.update_variant_quantity(params[:id], params[:quantity])
      head 200
    else
      head 500
    end
  end
end