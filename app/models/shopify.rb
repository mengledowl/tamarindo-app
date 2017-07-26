class Shopify
  def self.update_variant_quantity(id, quantity)
    variant = ShopifyAPI::Variant.find(id)
    variant.inventory_quantity = quantity
    variant.save
  end
end