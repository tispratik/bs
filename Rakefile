# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Bs::Application.load_tasks

#Following is Rails 2
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'delayed/tasks'
  require 'thinking_sphinx/tasks'
  require 'thinking_sphinx/deltas/delayed_delta/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install required gems"
end
