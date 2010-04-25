class Event < ActiveRecord::Base
  RECURRING_TYPES = ["Day", "Week", "Month", "Year"]
  # has_event_calendar
  belongs_to :calendar
  has_many :comments, :as => :commentable
  has_many :event_invitees
  
  validates_associated :calendar
  validates_presence_of :calendar_id, :summary, :start_at
  
  attr_accessor :start_hour, :start_min, :duration, :color
  
  before_validation_on_create :set_dates
  
  attr_writer :invitees
  def invitees
    @invitees || event_invitees.map{|inv| inv.user.contact.email}.join(', ')
  end
  
  def after_save
    if @invitees.is_a?(String)
      @invitees = @invitees.split(/,\s*/)
    end
    if @invitees.is_a?(Array)
      transaction do
        self.event_invitees = @invitees.map do |email|
          contact = Contact.find_by_email(email)
          event_invitees.create(:user => contact.contactable)
        end
      end
    end
  end
  
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
  
  # Creating set of proxy objects for recurring events
  # for displayiong on page
  class Proxy
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
    
    events = all(:conditions => ["(? <= end_at) AND (start_at < ?) or (repeat_frequency != '' and repeat_frequency is not null)", date_start, date_end])
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
          new_events << Proxy.new(event, date)
        end
      else
        new_events << Proxy.new(event, event.start_at)
      end
    end
    
    create_event_strips(date_start, date_end, new_events)
  end
  
end
