class Event < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :event_series
  has_many :comments, :as => :commentable
  has_many :event_invitees
  
  has_event_calendar
  
  validates_associated :calendar
  validates_presence_of :calendar_id, :summary, :start_at
  
  accepts_nested_attributes_for :event_series
  
  attr_accessor :start_hour, :start_min, :duration, :color
  attr_accessor :repeat_frequency, :repeat_until_date, :on_wdays
  
  before_validation_on_create :set_dates
  
  named_scope :all_events_for_users, lambda { |user_ids|
    { :conditions => ["created_by in (?) or 0 < (select count(id) from event_invitees where event_id=events.id and user_id in (?))", user_ids, user_ids] }
  }
  
  def attributes=(new_attributes, guard_protected_attributes = true)
    date_hack(new_attributes, "repeat_until_date")
    super(new_attributes, guard_protected_attributes)
  end

  def date_hack(attributes, property)
    keys, values = [], []
    attributes.each_key {|k| keys << k if k =~ /#{property}\(\di\)/ }
    unless keys.empty?
      keys.sort.each { |k| values << attributes[k]; attributes.delete(k); }
      date = Time.zone.local(*values)
      date = date.to_date unless values.size > 3
      attributes[property] = date
    end
  end
  
  def before_validation_on_create
    self.created_by = User.curr_user.id
  end
  
  def after_save
    if @invitees.is_a?(String)
      @invitees = @invitees.split(/,\s*/)
    end
    if @invitees.is_a?(Array)
      transaction do
        self.event_invitees = @invitees.map do |email|
          if user = User.find_by_login_email(email)
            event_invitees.create(:user => user)
          end
        end
      end
    end
  end
  
  def update_series(params)
    if event_series
      self.attributes = params
      event_series.attributes = params.reject { |k,v| k =~ /start_at|end_at/ }
      
      if changed.include?("start_at")
        event_series.start_at += changes["start_at"][1] - changes["start_at"][0]
      end
      if changed.include?("end_at")
        event_series.start_at += changes["end_at"][1] - changes["end_at"][0]
      end
    else
      build_event_series(params)
    end
    
    event_series.save
    event_series
  end
  
  def repeat_frequency
    event_series.try :repeat_frequency
  end
  
  def repeat_until_date
    event_series.try :repeat_until_date
  end
  
  def on_wdays
    event_series.try(:on_wdays)
  end
  
  attr_writer :invitees
  def invitees
    @invitees || event_invitees.map{|inv| inv.user.login_email}.join(', ')
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
    event_series_id.present?
  end
  
  def duration
    (end_at - start_at) / 3600 if start_at && end_at
  end
  
  def to_s
    summary
  end
  
  def color
    @color ||= "#9aa4ad"
  end
  
end
