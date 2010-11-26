Bs::Application.routes.draw do
  
  # registration and login
  resource  :registration, :as => :users, :only => [:new, :create, :edit, :update, :destroy], :path_names => {:new => 'sign_up'} do
    member do
      post :validate
    end
    get :regions 
    get :cities
  end
  
  # resource :user_session do
  #   get '/sign_in' => 'user_sessions#new', :as => :new_user_session
  #   post '/sign_in' => 'user_sessions#create', :as => :user_session
  #   get '/sign_out' => 'user_sessions#destroy', :as => :destroy_user_session
  # end
  
  get '/sign_in' => 'user_sessions#new', :as => :new_user_session
  post '/sign_in' => 'user_sessions#create', :as => :user_session
  get '/sign_out' => 'user_sessions#destroy', :as => :destroy_user_session
  
  resources :users do
    resources :calendars
    resources :events
    resources :comments do
      member do
        get :quote
      end
    end
    resources :projects
  end
  
  resources :projects do
    resources :users
    resources :notifications
    resources :comments do
      member do
        get :quote
      end
    end
    resources :tasks do
      resources :comments
      collection do
        get :search
      end
      member do
        get :reopen
      end
    end
  
    resources :alerts
    resources :assets
    get '/assets/:id/:style' => 'assets#show'
    get '/taskcsvexport' => 'tasks#export_csv'
    get '/expensecsvexport' =>  'expenses#export_csv'
    get '/timesheetcsvexport' => 'timesheets#export_csv'
    resources :calendars
    resources :events
    resources :wiki_pages do
      member do
        get :diff
        get :restore
      end
    end
    
    resources :articles do
      collection do
        get :suggest
        get :search
      end  
    end  
    resources :project_invitations, :as => :invitations do
      member do
        get :confirm 
        get :resend
      end
    end  
    resources :project_roles, :as => :roles
    resources :timesheets do
      collection do
        get :suggest
      end
    end  
    resources :timelogs
    resources :expenses do
      collection do
        get :suggest
      end  
    end
    resources :expenselogs
    resources :project_logos do
      get :image      
    end  
  end
  
  match "live_validations/:action" => "live_validations"
  root :to => 'users#me'
  
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end