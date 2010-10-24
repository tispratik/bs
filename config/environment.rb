# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Bs::Application.initialize!

#Following is Rails2
#Rails::Initializer.run do |config|
  #config.active_record.timestamped_migrations = false
  #config.active_record.observers = :article_observer, :comment_observer, :asset_observer, :task_observer, :wiki_page_observer
  #config.time_zone = 'UTC'
  #end

#Delayed::Worker.backend = :active_record
#ActionView::Base.sanitized_allowed_tags.delete 'div'

#require 'paperclip'
#require 'thinking_sphinx/deltas/delayed_delta'

#UrlStore.defaults = {:secret => '55668jkhjhjhj'}

# hack for using Time.zone.now instead of Time.now
#class Date
#def self.today
 #   current
#end
#end

Time::DATE_FORMATS[:default] = "%B %d, %Y %H:%M"
Date::DATE_FORMATS[:default] = "%B %d, %Y"
#ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[:default] = "%B %d, %Y %H:%M"
#ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:default] = "%B %d, %Y"
#ActionMailer::Base.raise_delivery_errors = true
