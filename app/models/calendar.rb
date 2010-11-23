require 'open-uri'

class Calendar < ActiveRecord::Base
  
  belongs_to :calendarable, :polymorphic => true
  has_many :events, :dependent => :destroy
  has_many :event_series, :dependent => :destroy
  
  before_create :load_from_url, :if => "url.present?"
  after_create :create_private_url_hash
    
  def create_private_url_hash
    self.private_url_hash = Digest::SHA1.hexdigest("#{name} #{Time.now} #{rand(10**10)}")
  end
  
  def validate
    unless name == "default"
      errors.add(:url, "can't be blank") unless url.present?
    end
  end
  
  def user
    (calendarable.is_a?(User)) ? calendarable : calendarable.user
  end
  
  def load_from_url
    ical = RiCal.parse(open(url)).first
    
    transaction do
      update_attributes(:name => ical.x_properties["X-WR-CALNAME"].first.value)
      ical.events.each do |event|
        
        params = {
          :calendar_id => id,
          :uid => event.uid,
          :sequence => event.sequence,
          :summary => event.summary,
          :location => event.location,
          :start_at => event.dtstart,
          :end_at => event.dtend
        }
        
        unless event.rrule_property.empty?
          rrule = event.rrule_property.first
          params.merge!(
            :repeat_frequency => rrule.freq.slice(0..-3).capitalize,
            :repeat_interval => rrule.interval,
            :repeat_until_date => rrule.until,
            :repeat_until_count => rrule.count
          )
          if rrule.by_list[:byday]
            params.merge!(:on_wdays => rrule.by_list[:byday].collect(&:wday).collect{|wday| EventSeries::WDAYS[wday]})
          end
          event_model = EventSeries
        else
          event_model = Event
        end
        
        if new_record? || !existing_event = event_model.find_by_uid_and_calendar_id(event.uid, id)
          existing_event = event_model.create(params)
        else
          existing_event.update(params) unless existing_event.sequence == event.sequence
        end
      end
      touch
    end
    nil
  end
end
