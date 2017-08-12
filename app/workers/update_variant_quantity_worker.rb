class UpdateVariantQuantityWorker
  include Sidekiq::Worker

  def perform(variant_id)
    variant = Variant.find(variant_id)
    ats = Logon.get_ats(style: variant.logon_style, col: variant.logon_col, dm: variant.logon_dm, size: variant.logon_size)

    Shopify.update_variant_quantity(variant.shopify_variant_id, ats.quantity)
  end
end