class ProductVariantsController < ApplicationController
  def show_quantity
    client = Savon.client(wsdl: Rails.root.join('app', 'middleware', 'logon_wsdl.xml'), proxy: ENV['FIXIE_URL'])

    # these are assumptions for now until we can see the actual data as it comes in
    response = client.call(:ats, { style: params[:ats_style] })

    body = response.body['rec'].first['item']

    render json: { style: params[:ats_style], quantity: body['quantity'] }
  end
end