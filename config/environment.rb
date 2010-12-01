RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  config.active_record.colorize_logging = true
  config.active_record.timestamped_migrations = false
  config.active_record.observers = :article_observer, :comment_observer, :asset_observer, :task_observer, :wiki_page_observer
  
  config.time_zone = 'UTC'
  
end

Delayed::Worker.backend = :active_record
ActionView::Base.sanitized_allowed_tags.delete 'div'

require 'paperclip'
require 'thinking_sphinx/deltas/delayed_delta'

UrlStore.defaults = {:secret => '55668jkhjhjhj'}

# hack for using Time.zone.now instead of Time.now
class Date
  def self.today
    current
  end
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[:default] = "%B %d, %Y %H:%M"
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:default] = "%B %d, %Y"
ActionMailer::Base.raise_delivery_errors = true
