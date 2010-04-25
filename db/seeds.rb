require "#{RAILS_ROOT}/db/blueprints"

[Project, Event, WikiPage, Article, Calendar].each(&:delete_all)

p "creating user calendar and events for that calendar"

User.all.each do |u|
  cal = Calendar.make(:calendarable => u)
  10.times do
    Event.make(:calendar => cal)
  end
end

user = User.first
User.curr_user = user

p "creating projects"
5.times do
  project = user.projects.make
  7.times do
    project.calendar.events.make
    project.wiki_pages.make
    project.assets.create(:data => File.open("#{RAILS_ROOT}/public/images/rails.png"))
    article = project.articles.make
    article.assets.create(:data => File.open("#{RAILS_ROOT}/public/images/rails.png"))
    t = project.tasks.make
    5.times do
      Comment.make(:commentable => t)
      Comment.make(:commentable => article)
    end
  end
end