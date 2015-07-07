require 'api_version'
Rails.application.routes.draw do

  #resources :payment_options

  #root :to=>"home#index"
  #get "sign_in" => "sessions#sign_in"
  #post "sign_in" => "sessions#login"

  #get "forgot_password" => "sessions#forgot_password"
  #put "forgot_password" => "sessions#send_password_reset_instructions"
  #get "password_reset" => "sessions#password_reset"
  #put "password_reset" => "sessions#new_password"
  #get "signed_out" => "sessions#signed_out"

  #resources :venues
  #resources :users
  #resources :products
  #resources :order_items
  #resources :orders

  match '*path', controller: :cors_options, action: 'handle_options_request',via: :options

  namespace :v1 do
    resources :users  do
      resources :payment_options
    end

    resources :sessions, only: [:create,:destroy]
    resources :venues do
      resources :products
      post 'products/upload', to: 'products#upload'
      resources :orders
    end
    get 'users/getbytoken/:token', to: 'users#get_by_token'
    post 'sessions/passwordreset', to: 'sessions#password_reset'
    post 'sessions/passwordupdate', to: 'sessions#password_update'
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with cors_options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
