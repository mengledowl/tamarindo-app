class Variant < ApplicationRecord
  def to_putorder_format(quantity)
    {
        style: self.logon_style,
        col: self.logon_col,
        dm: self.logon_dm,
        size: self.logon_size,
        quantity: quantity
    }
  end
end
