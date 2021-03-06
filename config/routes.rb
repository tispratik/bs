ActionController::Routing::Routes.draw do |map|
  
  # registration and login
  
  map.resource :registration, :only => [:new, :create, :edit, :update, :destroy], :as => :users,
      :path_names => {:new => :sign_up}, :member => {:validate => :post}, :collection => {:regions => :get, :cities => :get}
  
  map.with_options(:controller => 'user_sessions', :name_prefix => nil) do |session|
    session.new_user_session     "sign_in",  :action => :new, :conditions => {:method => :get}
    session.user_session         "sign_in",  :action => :create, :conditions => {:method => :post}
    session.destroy_user_session "sign_out", :action => :destroy, :conditions => {:method => :get}
  end
  
  map.resources :users do |users|
    users.resources :calendars
    users.resources :events
    users.resources :comments, :member => {:quote => :get}
    users.resources :projects
  end
  
  map.resources :projects do |projects|
    projects.resources :users
    projects.resources :notifications
    projects.resources :comments, :member => {:quote => :get}
    projects.resources :tasks, :collection => {:search => :get}, :member => {:reopen => :get}, :has_many => :comments
    projects.resources :alerts
    projects.resources :assets
    projects.connect '/assets/:id/:style', :controller => 'assets', :action => 'show', :conditions => {:method => :get}
    projects.connect '/taskcsvexport', :controller => "tasks", :action => 'export_csv', :conditions => {:method => :get}
    projects.connect '/expensecsvexport', :controller => "expenses", :action => 'export_csv', :conditions => {:method => :get}
    projects.connect '/timesheetcsvexport', :controller => "timesheets", :action => 'export_csv', :conditions => {:method => :get}
    projects.resources :calendars
    projects.resources :events
    projects.resources :wiki_pages, :member => {:diff => :get, :restore => :get}
    projects.resources :articles, :collection => {:suggest => :get, :search => :get}
    projects.resources :project_invitations, :as => :invitations, :member => {:confirm => :get, :resend => :get}
    projects.resources :project_roles, :as => :roles
    projects.resources :timesheets, :collection => {:suggest => :get}
    projects.resources :timelogs
    projects.resources :expenses, :collection => {:suggest => :get}
    projects.resources :expenselogs
    projects.resources :project_logos, :member => [ :image ]
  end
  
  map.connect "live_validations/:action", :controller => "live_validations"
  map.root :controller => :users, :action => :me  
  
end