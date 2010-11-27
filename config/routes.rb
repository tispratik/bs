Bs::Application.routes.draw do
  
  resource :registration, :as => :users, :only => [:new, :create, :edit, :update, :destroy], :path_names => {:new => 'sign_up'} do
    
    collection do
      get :regions
      get :cities
    end
    
    member do
      post :validate
    end
    
  end
  
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
    
    resources :project_invitations do
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
      member do
        :image
      end
    end
    
  end
  
  match "live_validations/:action" => "live_validations"
  root :to => 'users#me'
  
end
