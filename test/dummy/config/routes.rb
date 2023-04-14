Dummy::Application.routes.draw do

  get "status/:code" => 'status#index'

  get 'exception' => 'home#boom',   :as => :exception
  get 'slow'      => 'home#slow',   :as => :slow
  get 'custom'    => 'home#custom', :as => :custom

  get 'user/manipulation' => 'user#manipulation', :as => :user_manipulation

  get 'cache/read'      => 'cache#read',      :as => :cache_read
  get 'cache/write'     => 'cache#write',     :as => :cache_write
  get 'cache/fetch_hit' => 'cache#fetch_hit', :as => :cache_fetch_hit
  get 'cache/generate'  => 'cache#generate',  :as => :cache_generate
  get 'cache/delete'    => 'cache#delete',    :as => :cache_delete

  get 'render/partial'  => 'render#partial',  :as => :render_partial
  get 'render/template' => 'render#template', :as => :render_template

  get 'instrument/inst' => 'instrument_action#inst', :as => :instrument_action
  get 'instrument/not'  => 'instrument_action#not',  :as => :not_instrumented
  get '/invalid_format' => 'instrument_action#invalid_format'

  get 'base/action_1'         => 'base#action_1',         :as => :base_action_1
  get 'base/action_2'         => 'base#action_2',         :as => :base_action_2
  get 'intermediate/action_1' => 'intermediate#action_1', :as => :intermediate_action_1
  get 'derived/action_1'      => 'derived#action_1',      :as => :derived_action_1
  get 'derived/action_2'      => 'derived#action_2',      :as => :derived_action_2

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

end
