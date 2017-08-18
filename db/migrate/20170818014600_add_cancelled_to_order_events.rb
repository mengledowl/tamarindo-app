class AddCancelledToOrderEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :order_events, :cancelled, :boolean, default: false
  end
end
