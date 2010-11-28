Bs::Application.routes.draw do

  match 'live_validations/:action' => 'live_validations'
  root :to => 'users#me'
  get '/sign_in' => 'user_sessions#new', :as => :new_user_session
  post '/sign_in' => 'user_sessions#create', :as => :user_session
  get '/sign_out' => 'user_sessions#destroy', :as => :destroy_user_session

  resource :registration, :only => [:new, :create, :edit, :update, :destroy], :as => :users, :path_names => {:new => 'sign_up'} do
    get :regions
    get :cities
    member do
      post :validate
    end
  end
 
  resources :users do
    resources :projects
    resources :calendars
    resources :events
    resources :comments do
      member do
        get :quote
      end
    end
  end
  
  resources :projects do
    
    member do	
      get '/assets/:id/:style' => 'assets#show'
      get '/taskcsvexport' => 'tasks#export_csv'
      get '/expensecsvexport' =>  'expenses#export_csv'
      get '/timesheetcsvexport' => 'timesheets#export_csv'
    end    

    resources :users
    resources :notifications
    resources :alerts
    resources :assets
    resources :calendars
    resources :events
    resources :project_roles, :as => :roles
    resources :timelogs
    resources :expenselogs
    
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

    resources :timesheets do
      collection do
        get :suggest
      end
    end

    resources :expenses do
      collection do
        get :suggest
      end
    end

    resources :project_logos do
      member do
        :image
      end
    end

  end

end
