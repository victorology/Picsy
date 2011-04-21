Picsy::Application.routes.draw do
  devise_for :users
  
  devise_scope :user do
    post "check_sign_in", :to => "devise/sessions#check_sign_in"
    post "check_register", :to => "devise/sessions#check_register"
  end
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'items/filter/' => 'items#filter', :as => :items_filter
  match 'items/more/' => 'items#more', :as => :items_more
  match 'personalization/sub_categories/:id' => 'personalization#sub_categories'
  match 'personalization/user_creation' => 'personalization#user_creation'
  match 'personalization/ajax_user_creation' => 'personalization#ajax_user_creation'
  match 'personalization/show' => 'personalization#show'
  match 'my' => 'personalization#mydeals'
  match 'personalization/new_user' => 'personalization#new_user'
  match 'photo/:nickname/z:code' => 'photos#show'
  match 'photo/:nickname/t:code' => 'photos#show'
  match 'photo/:nickname/q:code' => 'photos#show'
  match 'photo/:nickname/x:code' => 'photos#show'
  match 'facebook/confirm_api/:session_api/id/:id.:format' => 'facebook#confirm_api'
  
  resources :home do
    collection do
      get 'crawl_rss'
      get 'run_scheduling'
    end  
  end  
  
  resources :launch do
    collection do
      get 'invite'
    end
  end    
  
  resources :poster
  
  resources :me2day
  
  resources :cyworld
  
  resources :connections
  
  resources :photos do 
    collection do 
      get 'mine'
    end
  end    
  
  resources :twitter do
    collection do 
      get 'confirm'
      post 'xauth_token'
      post 'xauth_login'
      get 'xauth_form'
      get 'assign_categories_locations'
      get 'unlink'
      post 'do_assign_categories_locations'
    end  
  end
  
  resources :facebook do
    collection do
      get 'confirm'
      get 'confirm_api'
      get 'unlink'
      get 'assign_categories_locations'
      post 'do_assign_categories_locations'
    end   
  end  
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
  namespace :admin do
    resources :home
    resources :items do
      collection do
        post "select"
        get "index_images"
        post "manage_images"
      end
      
      member do
        post "hide"
      end  
    end  
    resources :categories
    resources :item_logs
    resources :item_types
  end   

  resources :personalization do
    collection do
      get 'show'
      get 'user_sign_in'
      get 'sign_in_done'
      post 'check_sign_in'
	  end
  end

  resources :items do
	  collection do
      get 'filter'
		end
	end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "launch#index"

  # See how all your routes lay out with "rake routes"

  match 'z:code' => 'photos#shortened'
  match 't:code' => 'photos#shortened'
  match 'q:code' => 'photos#shortened'
  match 'x:code' => 'photos#shortened'
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
