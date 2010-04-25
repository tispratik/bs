class Event < ActiveRecord::Base
  RECURRING_TYPES = ["Day", "Week", "Month", "Year"]
  # has_event_calendar
  belongs_to :calendar
  
  validates_associated :calendar
  validates_presence_of :calendar, :summary, :start_at
  
  attr_accessor :start_hour, :start_min, :duration, :color
  
  before_validation_on_create :set_dates
  
  def set_dates
    # if start_hour && start_min
    #   self.start_at = Time.parse("#{start_hour}:#{start_min}")
    # end
    if @duration
      self.end_at = start_at + @duration.to_i.hours
    end
  end
  
  def recurring?
    repeat_frequency.present?
  end
  
  def duration
    (end_at - start_at) / 3600 if start_at && end_at
  end
  
  def to_s
    summary
  end
  
  ## Hack for recurring events here
  # Each event object wrapped into another class
  # with specific start/end dates like common event
  
  class Recurring
    include EventCalendar::InstanceMethods
    attr_accessor :event_object, :start_at, :end_at
    delegate :color, :to => :event_object
    delegate :id, :to => :event_object
    
    def initialize(event, date)
      self.event_object = event
      self.start_at = Time.parse("#{date.to_date} #{event.start_at.to_s(:time)}")
      self.end_at = start_at + event.duration.hours
    end
  end
  
  def color
    @color ||= "#9aa4ad"
  end
  
  def self.event_strips_for_month(shown_date)
    self.extend EventCalendar::ClassMethods
    date_start, date_end = get_start_and_end_dates(shown_date, 0)
    
    events = all(:conditions => ["(? <= end_at) AND (start_at < ?) or (repeat_frequency != '' and repeat_frequency != NULL)", date_start, date_end])
    new_events = []
    events.each do |event|
      if event.recurring?
        until_date = event.repeat_until_date || date_end
        opts = {:every => event.repeat_frequency.downcase.to_sym, :starts => event.start_at, :until => until_date}
        case opts[:every]
          when :week  then opts[:on] = event.start_at.wday
          when :month then opts[:on] = event.start_at.day
          when :year  then opts[:on] = [event.start_at.month, event.start_at.day]
        end
        Recurrence.new(opts).each do |date|
          new_events << Recurring.new(event, date)
        end
      else
        new_events << Recurring.new(event, event.start_at)
      end
    end
    
    create_event_strips(date_start, date_end, new_events)
  end
  
end
