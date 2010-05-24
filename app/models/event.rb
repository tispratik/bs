require 'digest/sha1'

class Event < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :event_series
  has_many :comments, :as => :commentable
  has_many :event_invitees
  belongs_to :creator, :class_name => 'User', :foreign_key => "created_by"
  
  has_event_calendar
  
  validates_associated :calendar
  validates_presence_of :calendar_id, :summary, :start_at
  
  accepts_nested_attributes_for :event_series
  
  attr_accessor :start_hour, :start_min, :duration, :color
  attr_accessor :repeat_frequency, :repeat_until, :repeat_until_date, :repeat_until_count, :on_wdays
  attr_accessor :start_at_date, :invitee_ids
  
  before_validation_on_create :set_dates
  
  named_scope :all_events_for_users, lambda { |user_ids|
    { :conditions => ["created_by in (?) or 0 < (select count(id) from event_invitees where event_id=events.id and user_id in (?))", user_ids, user_ids] }
  }
  named_scope :all_events_for_project_or_users, lambda { |project_id, user_ids|
    { :conditions => ["calendars.calendarable_type='Project' and calendars.calendarable_id=? or created_by in (?)", project_id, user_ids],
      :joins => :calendar
    }
  }
  
  def attributes=(new_attributes, guard_protected_attributes = true)
    date_hack(new_attributes, "repeat_until_date")
    super(new_attributes, guard_protected_attributes)
    
    # merge date with time
    if start_at_date.present?
      self.start_at = "#{start_at_date} #{start_at.to_s(:time)}"
    end
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
  
  def validate
    if self.start_at > self.end_at
      errors.add(:start_at, 'must be earlier than end date')
    end
  end
  
  def before_validation_on_create
    self.created_by = User.curr_user.id
    self.uid = "calendar@#{Digest::SHA1.hexdigest((Time.now.to_f + rand).to_s)}" unless uid.present?
  end
  
  def after_save
    if @invitees.present?
      if @invitees.is_a?(String)
        @invitees = @invitees.split(/,\s*/)
      end
      if @invitees.is_a?(Array)
        transaction do
          # removing invitees that aren't in new list
          event_invitees.each do |invitee|
            unless @invitees.include?(invitee.user_email) || (invitee.user && @invitees.include?(invitee.user.login_email))
              invitee.destroy
            end
          end
          # adding new invitees
          @invitees.each do |email|
            next if event_invitees.find_by_user_email(email)
            
            if user = User.find_by_username_or_login_email(email)
              event_invitees.create(:user => user, :user_email => user.login_email)
            else
              event_invitees.create(:user_email => email)
            end
          end
        end
      end
    end
    if @invitee_ids.present?
      transaction do
        self.event_invitees = @invitee_ids.map { |user_id|
          user = User.find(user_id)
          if user
            event_invitees.create(:user => user, :user_email => user.login_email)
          end
        }.compact
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
  
  def repeat_until
    if repeat_until_date.present?
      "date"
    elsif repeat_until_count.present?
      "count"
    else
      "never"
    end
  end
  
  def repeat_frequency
    event_series.try :repeat_frequency
  end
  
  def repeat_until_date
    event_series.try :repeat_until_date
  end
  
  def repeat_until_count
    event_series.try :repeat_until_count
  end
  
  def on_wdays
    event_series.try(:on_wdays)
  end
  
  attr_writer :invitees
  def invitees
    @invitees || event_invitees.map{|inv| inv.user_email}.join(', ')
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
  
  def to_s(format = :summary)
    if format == :smart
      title = calendar.calendarable_type == "User" ? creator : summary
    else
      title = (format == :owner) ? creator : summary
    end
    if all_day?
      "All Day: #{title}"
    else
      "#{start_at.strftime('%H%M')}-#{end_at.strftime('%H%M')}: #{title}"
    end
  end
  
  def color
    @color ||= "#066A9C"
  end
  
  def send_emails_to_invitees(sender)
    event_invitees.each do |invitee|
      unless invitee.email_sent?
        UserMailer.deliver_event_invitation(invitee.user_email, sender)
        invitee.update_attributes(:email_sent => true)
      end
    end
  end
  
  def upcomingheader
    if all_day?
    return summary
    else
    mins = start_at.min.to_s()
    if mins == "0"
      mins = "00"
    end
    return start_at.hour.to_s() + mins + ": " + summary
    end
  end
  
  def header_tooltip
    if all_day?
    return "All day: "+ summary
    else
    mins_start = start_at.min.to_s()
    mins_end = end_at.min.to_s()
    if mins_start == "0"
      mins_start = "00"
    end
    if mins_end == "0" 
      mins_end = "00"
    end
    return start_at.hour.to_s() + mins_start + " - " + end_at.hour.to_s() + mins_end + ": " + summary
    end
  end
    
end