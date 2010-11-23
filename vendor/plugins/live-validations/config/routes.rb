Rails.application.routes.draw do
  match 'live_validations/:action', :controller => 'live_validations'
end
