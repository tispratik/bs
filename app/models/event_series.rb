class EventSeries < ActiveRecord::Base
  RECURRING_TYPES = ["Day", "Week", "Month", "Year"]
  WDAYS = ["Sun", "Mon", "Tue", "Wen", "Thu", "Fri", "Sat"]
  UNTIL_TYPES = ["never", "date", "count"]
  
  belongs_to :calendar
  has_many :events, :dependent => :destroy
  
  validates_presence_of :repeat_frequency
  validates_presence_of :calendar_id
  
  after_create :create_events
  
  attr_accessor :duration, :repeat_until
  serialize :on_wdays
  serialize :invitees
  
  def before_validation_on_create
    if duration
      self.end_at = start_at + duration.to_i.hours
    end
    self.created_by = User.curr_user.id
  end
  
  def before_save
    self.on_wdays = (on_wdays & WDAYS)
    @changed_attrs = changed
  end
  
  def after_update
    series_changes = ["start_at", "end_at", "repeat_frequency", "repeat_interval", "repeat_until_date", "repeat_until_count", "on_wdays"]
    if @changed_attrs.any?{|c| series_changes.include?(c) }
      create_events
    else
      params = {}
      @changed_attrs.each do |attr_name|
        params[attr_name.to_sym] = send(attr_name)
      end
      unless params.empty?
        events.update_all(params)
      end
    end
  end
  
  def create_events
    events.destroy_all
    
    until_date = repeat_until_date || (Time.current + 1.year)
    opts = {:every => repeat_frequency.downcase.to_sym, :starts => start_at, :until => until_date.to_date}
    opts[:on] = case opts[:every]
      when :week  then
        unless on_wdays.empty?
          on_wdays.collect{ |d| WDAYS.index(d) }
        else
          start_at.wday
        end
      when :month then start_at.day
      when :year  then [start_at.month, start_at.day]
    end
    transaction do
      Recurrence.new(opts).each do |date|
        event = events.build(
          :calendar_id => calendar_id,
          :uid => uid,
          :sequence => sequence,
          :summary => summary,
          :location => location,
          :all_day => all_day?,
          :start_at => date.to_time + (start_at - start_at.beginning_of_day),
          :end_at => date.to_time + (end_at - start_at),
          :invitees => invitees,
          :created_by => created_by
        )
        event.save(false)
      end
    end
    
  end
  
end