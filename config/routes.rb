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
  end
  
  map.resources :projects do |projects|
    projects.resources :users
    projects.resources :tasks, :collection => {:search => :get}, :member => {:reopen => :get}, :has_many => :comments
    projects.resources :assets
    projects.connect '/assets/:id/:style', :controller => 'assets', :action => 'show', :conditions => {:method => :get}
    projects.resources :calendars
    projects.resources :events
    projects.resources :wiki_pages, :member => {:diff => :get, :restore => :get}
    projects.resources :articles, :collection => {:suggest => :get, :search => :get}
    projects.resources :project_invitations, :as => :invitations, :member => {:confirm => :get}
    projects.resources :project_roles, :as => :roles
  end
  
  map.connect "live_validations/:action", :controller => "live_validations"
  map.resources :comments, :member => {:quote => :get}
  map.root :controller => :users, :action => :me
  
end