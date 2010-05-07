require 'open-uri'
require 'digest/sha1'

namespace :calendars do
  
  desc "Checking updates for all user's calendars"
  task :update_all => :environment do
    Calendar.all.each do |calendar|
      if calendar.url.present? && calendar.updated_at + 1.hour < Time.now
        puts "Updating calendar #{calendar.name} with id=#{calendar.id}.."
        calendar.load_from_url
      end
    end
  end
  
end