class Logon::Ats
  attr_accessor :data, :style

  def initialize(data:, style:)
    @data = data
    @style = style
  end

  def quantity
    data.dig(:ats_response, :rec, :item, :quantity)
  end

  def to_json(options=nil)
    {
        style: style,
        quantity: quantity
    }.to_json
  end
end