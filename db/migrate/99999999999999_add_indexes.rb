class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index 'comments', 'parent_id'
    add_index 'alerts', 'project_id'
    add_index 'alerts', 'alertable_id'
    add_index 'timesheets', 'user_id'
    add_index 'timesheets', 'project_id'
    add_index 'timesheets', 'objectable_id'
    add_index 'tags', 'project_id'
    add_index 'events', 'event_series_id'
    add_index 'event_series', 'calendar_id'
    add_index 'event_invitees', 'event_id'
    add_index 'event_invitees', 'user_id'
    add_index 'timelogs', 'timesheet_id'
    add_index 'timelogs', 'project_id'
  end
end