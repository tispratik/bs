module CalendarHelper
  def month_link(month_date)
    link_to(I18n.localize(month_date, :format => "%B"), request.query_parameters.merge(:month => month_date.month, :year => month_date.year))
  end
  
  # custom options for this calendar
  def event_calendar_opts
    { 
      :year => @year,
      :month => @month,
      :event_strips => @event_strips,
      :month_name_text => I18n.localize(@shown_month, :format => "%B %Y"),
      :previous_month_text => "<< " + month_link(@shown_month.last_month),
      :next_month_text => month_link(@shown_month.next_month) + " >>"    }
  end

  def event_calendar
    # args is an argument hash containing :event, :day, and :options
    calendar event_calendar_opts do |args|
      event = args[:event]
      
      format = :summary
      if @calendarable.is_a?(Project) && event.calendar.calendarable != @calendarable
        format = :owner
      end
      title = event.to_s(format)
      link_to "#{event.recurring? ? "(R)" : ""} #{h title}", [event.calendar.calendarable, event], :title => h(title)
    end
  end
end