Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post :update_variant_quantity, to: 'callbacks#update_variant_quantity'

  get :show_quantity, to: 'product_variants#show_quantity'
end
