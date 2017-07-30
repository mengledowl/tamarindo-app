class CreateOrderEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :order_events do |t|
      t.integer :shopify_order_id, limit: 8
      t.boolean :processed, default: false

      t.timestamps
    end
  end
end
