require 'machinist/active_record'
require 'random_data'
require 'faker'
require 'populator'
require 'time_extensions'

due_dates = [Date.today, Date.tomorrow, Date.yesterday, Date.today.end_of_week, Date.today.beginning_of_month, Date.today.end_of_month]

Project.blueprint do
  name          { Faker::Company.name }
  permalink     { Random.alphanumeric }
  status        { Project::STATUSES.rand.id }
  description   { Faker::Lorem.paragraph }
  objectives    { Faker::Lorem.paragraph }
end

Event.blueprint do
  summary       { Faker::Lorem.sentence }
  location      { Faker::Address.city }
  start_at      { Random.date }
  end_at        { start_at + rand(40).hours }
end

WikiPage.blueprint do
  title         { Faker::Lorem.sentence }
  content       { Faker::Lorem.paragraphs.join("\n\n") }
end

Article.blueprint do
  title         { Faker::Lorem.sentence }
  content       { Faker::Lorem.paragraphs.join("\n\n") }
  tag_list      { Faker::Lorem.words.join(',') }
  citation_author { Faker::Name.name }
  citation_source { Faker::Internet.domain_name }
  citation_date { Random.date }
end

Calendar.blueprint do
  name         { Faker::Lorem.words.join(" ") }
end

Task.blueprint do
  name          { Faker::Company.name }
  description   { Populator.sentences(1..2) }
  assign_to     { [1,2,3,4,5].rand }
  due_date      { due_dates.rand } 
  task_type     { Task::TYPES.rand.id }
  priority      { Task::PRIORITIES.rand.id }
  status        { Decode::BS_TASK_STATUS_OP }
end

Comment.blueprint do
  message       { Faker::Lorem.paragraph }
  is_spam       { Random.boolean }
end        