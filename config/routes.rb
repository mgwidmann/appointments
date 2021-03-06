require 'sidekiq/web'

Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, controllers: {sessions: 'sessions', registrations: 'registrations'}
  get "/users/profile", controller: :users, action: :profile, as: :profile
  put "/users/profile", controller: :users, action: :update_profile, as: :update_profile
  get '/settings', controller: :settings, action: :index, as: :settings
  get '/closings', controller: :closings, action: :index, as: :closings
  get '/reauth/:token', controller: :reauth, action: :reauth
  scope "/admin" do
    get "/", controller: :admin, action: :index, as: :admin_index
    resources :users, as: :admin_users
    resources :appointment_types, as: :admin_appointment_types
    resources :appointments, as: :admin_appointments
    resources :announcements, as: :admin_announcements
    resources :settings, as: :admin_settings
    resources :closings, only: [:create, :update, :destroy], as: :admin_closings
    authenticate :user, lambda { |u| u.admin_or_staff? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'appointments#index'

  resources :appointment_types, only: [:index, :show], format: :json

  resources :appointments do
    collection do
      get :stage
    end
  end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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
