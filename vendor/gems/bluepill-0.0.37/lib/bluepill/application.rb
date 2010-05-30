require 'thread'

module Bluepill
  class Application
    PROCESS_COMMANDS = [:start, :stop, :restart, :unmonitor, :status]
    
    attr_accessor :name, :logger, :base_dir, :socket, :pid_file
    attr_accessor :groups, :work_queue
    attr_accessor :pids_dir, :log_file

    def initialize(name, options = {})
      self.name = name

      @foreground   = options[:foreground]
      self.log_file = options[:log_file]      
      self.base_dir = options[:base_dir] || '/var/bluepill'
      self.pid_file = File.join(self.base_dir, 'pids', self.name + ".pid")
      self.pids_dir = File.join(self.base_dir, 'pids', self.name)

      self.groups = {}
      
      self.logger = Bluepill::Logger.new(:log_file => self.log_file, :stdout => foreground?).prefix_with(self.name)
      
      self.setup_signal_traps
      self.setup_pids_dir
      
      @mutex = Mutex.new
    end

    def foreground?
      !!@foreground
    end

    def mutex(&b)
      @mutex.synchronize(&b)
    end

    def load
      begin
        self.start_server
      rescue StandardError => e
        $stderr.puts "Failed to start bluepill:"
        $stderr.puts "%s `%s`" % [e.class.name, e.message]
        $stderr.puts e.backtrace
        exit(5)
      end
    end
    
    PROCESS_COMMANDS.each do |command|
      class_eval <<-END
        def #{command}(group_name = nil, process_name = nil)
          self.send_to_process_or_group(:#{command}, group_name, process_name)
        end
      END
    end
    
    def add_process(process, group_name = nil)
      group_name = group_name.to_s if group_name
      
      self.groups[group_name] ||= Group.new(group_name, :logger => self.logger.prefix_with(group_name))
      self.groups[group_name].add_process(process)
    end
    
    def version
      Bluepill::VERSION
    end

    protected
    def send_to_process_or_group(method, group_name, process_name)
      if group_name.nil? && process_name.nil?
        self.groups.values.collect do |group|
          group.send(method)
        end.flatten
      elsif self.groups.key?(group_name)
        self.groups[group_name].send(method, process_name)
      elsif process_name.nil?
        # they must be targeting just by process name
        process_name = group_name
        self.groups.values.collect do |group|
          group.send(method, process_name)
        end.flatten
      else
        []
      end
    end

    def start_listener
      @listener_thread.kill if @listener_thread
      @listener_thread = Thread.new do
        loop do
          begin
            client = self.socket.accept
            command, *args = client.readline.strip.split(":")
            response = begin
              mutex { self.send(command, *args) }
            rescue Exception => e
              e
            end
            client.write(Marshal.dump(response))
          rescue StandardError => e
            logger.err("Got exception in cmd listener: %s `%s`" % [e.class.name, e.message])
            e.backtrace.each {|l| logger.err(l)}
          ensure
            begin
              client.close
            rescue IOError
              # closed stream
            end
          end
        end
      end
    end
    
    def start_server
      self.kill_previous_bluepill
      
      Daemonize.daemonize unless foreground?
      
      self.logger.reopen
      
      $0 = "bluepilld: #{self.name}"
      
      self.groups.each {|_, group| group.determine_initial_state }

      
      self.write_pid_file
      self.socket = Bluepill::Socket.server(self.base_dir, self.name)
      self.start_listener
      
      self.run
    end
    
    def run
      @running = true # set to false by signal trap
      while @running
        mutex do
          System.reset_data
          self.groups.each { |_, group| group.tick }
        end
        sleep 1
      end
      cleanup
    end
    
    def cleanup
      File.unlink(self.socket.path) if self.socket
      File.unlink(self.pid_file) if File.exists?(self.pid_file)
    end
    
    def setup_signal_traps
      terminator = lambda do
        puts "Terminating..."
        @running = false
      end
      
      Signal.trap("TERM", &terminator) 
      Signal.trap("INT", &terminator) 
      
      Signal.trap("HUP") do
        self.logger.reopen if self.logger
      end
    end
    
    def setup_pids_dir
      FileUtils.mkdir_p(self.pids_dir) unless File.exists?(self.pids_dir)
      # we need everybody to be able to write to the pids_dir as processes managed by
      # bluepill will be writing to this dir after they've dropped privileges
      FileUtils.chmod(0777, self.pids_dir)
    end
    
    def kill_previous_bluepill
      if File.exists?(self.pid_file)
        previous_pid = File.read(self.pid_file).to_i
        begin
          ::Process.kill(0, previous_pid)
          puts "Killing previous bluepilld[#{previous_pid}]"
          ::Process.kill(2, previous_pid)
        rescue Exception => e
          $stderr.puts "Encountered error trying to kill previous bluepill:"
          $stderr.puts "#{e.class}: #{e.message}"
          exit(4) unless e.is_a?(Errno::ESRCH)
        else
          10.times do |i|
            sleep 0.5
            break unless System.pid_alive?(previous_pid)
          end
          
          if System.pid_alive?(previous_pid)
            $stderr.puts "Previous bluepilld[#{previous_pid}] didn't die"
            exit(4)
          end
        end
      end
    end
    
    def write_pid_file
      File.open(self.pid_file, 'w') { |x| x.write(::Process.pid) }
    end
  end
end
