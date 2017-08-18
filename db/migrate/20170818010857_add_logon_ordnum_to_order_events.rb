class AddLogonOrdnumToOrderEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :order_events, :logon_ordnum, :integer
  end
end
