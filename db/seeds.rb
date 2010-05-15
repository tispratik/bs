require "#{RAILS_ROOT}/db/blueprints"

[Project, Event, WikiPage, Article, Calendar, Comment, Task, Asset, ProjectRole].each(&:destroy_all)

p "creating user calendar and events for that calendar"

User.all.each do |u|
  User.curr_user = u
  cal = u.calendars.make(:name => "default")
  10.times do
    cal.events.make
  end
end

user = User.curr_user = User.first

p "creating projects"
5.times do
  project = user.projects.make
  7.times do
    project.calendar.events.make
    project.wiki_pages.make
    project.assets.create(:orig_name => Random.firstname,:data => File.open("#{RAILS_ROOT}/public/images/rails.png"))
    article = project.articles.make
    article.assets.create(:orig_name => Random.firstname, :data => File.open("#{RAILS_ROOT}/public/images/rails.png"))
    task = project.tasks.make
    5.times do
      task.comments.make
      article.comments.make
    end
  end
end