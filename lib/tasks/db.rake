require 'active_record/fixtures'
require 'find' 

namespace :db do
  
  #preload models 
  task :load_decode => :environment do 
    # relative path assumes this is defined in a file in lib/tasks 
    puts File.dirname(__FILE__) + '/../../app/models/decode.rb'
    Dir[File.dirname(__FILE__) + '/../../app/models/decode.rb'].each do |file| 
      puts "Loading Model: " + file
      require file 
    end 
  end
  
  desc "Seed the database with always/ fixtures."
  task :always => [:environment] do 
    load_fixtures "seed/always", :always
  end
  
  desc "Seed the database with before_others/ fixtures."
  task :decodes => [:environment] do 
    load_fixtures "seed/before_others", :always
  end
  
  desc "Seed the database with always/ fixtures."
  task :ref_data_from_migration => [:environment] do 
    load_fixtures "seed/always", :always
  end
  
  desc "Seed the database with once/ fixtures."
  task :once => :environment do 
    load_fixtures "seed/once"
  end
  
  desc "Seed the database with develop/ fixtures."
  task :develop => :environment do 
    load_fixtures 'seed/develop', :always
  end
  
  desc "Refresh Database, drop, create and migrate."
  task :refresh => [:environment, :development_environment_only, :drop, :create, :migrate] do 
  end
  
  private
  
  def load_fixtures(dir, always = false)
    Dir.glob(File.join(Rails.root, 'db', dir, '*.yml')).each do |fixture_file|
      puts "File: " + fixture_file
      table_name = File.basename(fixture_file, '.yml')
      
      if table_empty?(table_name) || always
        truncate_table(table_name)
        Fixtures.create_fixtures(File.join('db/', dir), table_name)
      end
    end
  end  
  
  def table_empty?(table_name)
    quoted = connection.quote_table_name(table_name)
    connection.select_value("SELECT COUNT(*) FROM #{quoted}").to_i.zero?
  end
  
  def truncate_table(table_name)
    quoted = connection.quote_table_name(table_name)
    connection.execute("DELETE FROM #{quoted}")
  end
  
  def connection
    ActiveRecord::Base.connection
  end
  
  desc "Backup the database to a file. Options: DIR=base_dir Rails.env=production MAX=20"
  task :backup => [:environment] do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")    
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{Rails.env}_dump.sql")    
    FileUtils.makedirs(backup_folder)    
    db_config = ActiveRecord::Base.configurations[Rails.env]   
    sh "mysqldump -u #{db_config['username'].to_s} #{'-p' if db_config['password']}#{db_config['password'].to_s} --opt #{db_config['database']} > #{backup_file}"     
    dir = Dir.new(backup_base)
    all_backups = (dir.entries - ['.', '..']).sort.reverse
    puts "Created backup: #{backup_file}"     
    max_backups = ENV["MAX"] || 20
    unwanted_backups = all_backups[max_backups.to_i..-1] || []
    for unwanted_backup in unwanted_backups
      FileUtils.rm_rf(File.join(backup_base, unwanted_backup))
      puts "deleted #{unwanted_backup}"
    end
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available"
  end
  
  desc "Raise an error unless the Rails.env is development"
  task :development_environment_only do
    raise "Hey, development only you monkey!" unless Rails.env == 'development'
  end
  
  task :test_data => [:environment, :development_environment_only] do
    #file = Dir["db/migrate/#{ENV["VERSION"]}_*.rb"].first
    file = Dir["db/migrate/*test_data.rb"].first
    require(file)
    migration_class = file.scan(/([0-9]+)_([_a-z0-9]*).rb/)[0][1].camelize.constantize
    migration_class.migrate(:down) unless ENV["DIRECTION"] == 'up'
    migration_class.migrate(:up) unless ENV["DIRECTION"] == 'down'
  end
  
  
  desc "Loads images from public/images directory to database"
  task :image_seed => :environment do
    Dir.chdir(File.join(Rails.root,"public/images"))
    @image_paths = Dir["*.png"]
    
    for asset in @image_paths
      path = File.join(Rails.root, "public/images", asset)
      asset = Asset.create #create, as we need id for file name interpolation
      asset.data = File.new(path)
      puts asset.save ? "Image: #{asset.data_file_name} added successfully" : "Problem saving image: #{asset.data_file_name}"
    end
  end
  
  desc "Destroy all data in development environment."
  task :destroy_data => [:environment, :development_environment_only] do
    puts "==  Data: Destroying all data ".ljust(79, "=")
    sql = ActiveRecord::Base.connection()
 
    sql.execute "SET autocommit=0"
    sql.begin_db_transaction
 
    if sql.adapter_name == "MySQL"
      sql.execute("/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */")
      sql.execute("/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */")
    end
 
    tables = sql.tables - ["schema_migrations"]
 
    tables.each do |table|
      puts "-- Deleting all for #{table}."
      # So far, disabling and enabling keys was not needed.
      #sql.execute("/*!40000 ALTER TABLE `#{table}` DISABLE KEYS */") if sql.adapter_name == "MySQL"
      record_count = sql.delete("DELETE FROM `#{table}`")
      #sql.execute("/*!40000 ALTER TABLE `#{table}` ENABLE KEYS */") if sql.adapter_name == "MySQL"
      puts "   -> done: #{record_count} reconds"
    end
 
    if sql.adapter_name == "MySQL"
      sql.execute("/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */")
      sql.execute("/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */")
    end
 
    sql.commit_db_transaction
 
    puts "==  Data: Destroying all data (done) ".ljust(79, "=") + "\n\n"
  end
end
