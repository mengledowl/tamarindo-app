class OrderEvent < ApplicationRecord
  validates_uniqueness_of :shopify_order_id
end
