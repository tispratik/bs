ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

# Webrat.configure do |config|
#   config.mode = :rails
# end

require "#{RAILS_ROOT}/db/blueprints"

require 'capybara/rails'

# Capybara.default_driver = :selenium
Capybara.default_selector = :css

class ActionController::IntegrationTest
  include Capybara
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end

class ActionController::IntegrationTest
  def login_user(user=nil)
    unless user
      @current_user = User.make(:password => "secret")
    end
    visit new_user_session_path
    within "form#new_user_session" do
      fill_in "Username", :with => @current_user.username
      fill_in "Password", :with => "secret"
      click_button "Sign in"
    end
  end
end