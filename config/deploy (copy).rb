# RVM Bootstrap
$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
require 'thinking_sphinx/deploy/capistrano'
set :rvm_ruby_string, '1.8.7'
set :rvm_type, :system # :system or :user – user looks for rvm in $HOME/.rvm where as system uses the /usr/local as set for system wide installs.
# set :rvm_bin_path '/usr/local/rvm/bin' # or '~/.rvm/bin' the full path to your rvm install’s bin folder if the above dont work for your setup.

# Bundler Bootstrap
require 'bundler/capistrano'

# Application Details
set :application, "bs"
set :domain, "viridian.in"

# Server Roles 
role :app, domain.to_s 
role :web, domain.to_s 
role :db, domain.to_s, :primary => true 

# server details
ssh_options[:port] = 55848
set :user, "deploy"
set :use_sudo, false
default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

# Repo Details
set :scm, :git
set :scm_username, "tispratik@gmail.com"
set :repository, "git@github.com:tispratik/bs.git"
set :branch, "master"
set :deploy_to, "/home/deploy/public_html/bs"
set :deploy_via, :remote_cache
#set :git_enable_submodules, 1

# Thin Config
set :runner, user unless exists?(:runner) 
set :server_type, :thin unless exists?(:server_type) 
set :deploy_port, 4000 unless exists?(:deploy_port) 

set :keep_releases, 2 unless exists?(:keep_releases) 

# Paths
set :shared_database_path, "#{shared_path}/databases" 
set :shared_config_path, "#{shared_path}/config" 

# Our helper methods 
def public_configuration_location_for(server = :thin) 
  "#{current_path}/config/#{server}.yml" 
end

def shared_configuration_location_for(server = :thin) 
  "#{shared_config_path}/#{server}.yml" 
end 

# Config
namespace :configuration do 
  desc "Links the local copies of the shared images folder" 
  task :localize, :roles => :app do 
    run "rm -rf #{public_uploaded_images_path}" # God. Damned. Reversing it removes ALL images. Not fun. 
    run "ln -nsf #{shared_uploaded_images_path} #{public_uploaded_images_path}" 
  end 
  
  desc "Makes link for database"
  task :make_default_folders, :roles => :app do 
    run "mkdir -p #{shared_config_path}" 
    run "mkdir -p #{shared_uploaded_images_path}" 
  end 
end

# Thin  
namespace :thin do 
  desc "Generate a thin configuration file" 
  task :build_configuration, :roles => :app do 
    config_options = { "user" => (runner || user), 
      "group" => (runner || user), 
      "log" => "#{current_path}/log/thin.log", 
      "chdir" => current_path, 
      "port" => deploy_port, 
      "servers" => cluster_instances.to_i, 
      "environment" => "production", 
      "address" => "localhost", 
      "pid" => "#{current_path}/tmp/pids/log.pid" }.to_yaml 
      put config_options, shared_configuration_location_for(:thin) 
  end 
    
  desc "Links the configuration file" 
  task :link_configuration_file, :roles => :app do 
    run "ln -nsf #{shared_configuration_location_for(:thin)} #{public_configuration_location_for(:thin)}" 
  end 
    
  desc "Setup Thin Cluster After Code Update" 
  task :link_global_configuration, :roles => :app do 
    run "ln -nsf #{shared_configuration_location_for(:thin)} /etc/thin/#{application}.yml" 
  end 
    
  %w(start stop restart).each do |action| 
      
  desc "#{action} this app's Thin Cluster" 
    task action.to_sym, :roles => :app do 
      run "thin #{action} -C #{shared_configuration_location_for(:thin)}"
    end 
  end 
end

# Database
namespace :db do
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end  

# Bundler
namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
end

# Our magic 
namespace :deploy do 
  desc "Link up Sphinx's indexes."
  task :symlink, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end

  %w(start stop restart).each do |action| 
    desc "#{action} our server" 
    task action.to_sym do 
      find_and_execute_task("#{server_type}:#{action}") 
    end 
  end 
end

after "deploy:update_code", "bundler:bundle_new_release"
after "deploy:setup", "thinking_sphinx:shared_sphinx_folder"
after "deploy:restart", "thinking_sphinx:rebuild"
after "deploy", "deploy:cleanup"