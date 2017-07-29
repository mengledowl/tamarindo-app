Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post :update_variant_quantity, to: 'callbacks#update_variant_quantity'

  resources :logon_ats, only: :show

  post :shopify_webhook, to: 'shopify_webhook#order_created'
end
