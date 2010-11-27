#require 'geoip'
class Visit < ActiveRecord::Base
    
    def self.createVisitLog(username, request)
      stat = Visit.new
      stat.username = username
      #stat.ip = request.env['REMOTE_ADDR']
      stat.ip='24.171.23.184'
      geoipobj = GeoIP.new("C://rubyonrails//rails_apps//launchpad//private//geoip//geolitecity.dat").country(stat.ip)
      if geoipobj != nil
        stat.latitude = geoipobj[9]
        stat.longitude = geoipobj[10]
        stat.country = Country.first(:conditions => { :iso3 => geoipobj[3] }).ison
        stat.state = geoipobj[2] + "." + geoipobj[6]
        stat.city = geoipobj[7]
        stat.zip = geoipobj[8]
      end
      stat.save
      return stat
    end
    
end
