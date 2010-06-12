  #Bluepill gems
  config.gem 'bluepill'
  config.gem 'blankslate'  
  config.gem 'state_machine'    
  
  config.cache_classes = true
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true
  config.action_view.cache_template_loading            = true
  
  config.action_mailer.default_content_type = "text/html"
  config.action_mailer.default_charset = "utf-8"
  config.action_mailer.default_url_options = { :host => 'backstage.viridian.railsplayground.net' }