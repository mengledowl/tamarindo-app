class MakeShopifyVariantIdString < ActiveRecord::Migration[5.1]
  def change
    change_column :variants, :shopify_variant_id, :string
  end
end
