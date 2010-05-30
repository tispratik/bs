# Bluepill
Bluepill is a simple process monitoring tool written in Ruby. 

## Installation
It's hosted on [gemcutter.org][gemcutter].

    sudo gem install bluepill
    
In order to take advantage of logging with syslog, you also need to setup your syslog to log the local6 facility. Edit the appropriate config file for your syslogger (/etc/syslog.conf for syslog) and add a line for local6:

    local6.*          /var/log/bluepill.log
    
You'll also want to add _/var/log/bluepill.log_ to _/etc/logrotate.d/syslog_ so that it gets rotated.

Lastly, create the _/var/bluepill_ directory for bluepill to store its pid and sock files.

## Usage
### Config
Bluepill organizes processes into 3 levels: application -> group -> process. Each process has a few attributes that tell bluepill how to start, stop, and restart it, where to look or put the pid file, what process conditions to monitor and the options for each of those.

The minimum config file looks something like this:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
      end
    end
    
Note that since we specified a PID file and start command, bluepill assumes the process will daemonize itself. If we wanted bluepill to daemonize it for us, we can do (note we still need to specify a PID file):

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
        process.daemonize = true
      end
    end
    
If you don't specify a stop command, a TERM signal will be sent by default. Similarly, the default restart action is to issue stop and then start.

Now if we want to do something more meaningful, like actually monitor the process, we do:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
        
        process.checks :cpu_usage, :every => 10.seconds, :below => 5, :times => 3
      end
    end
    
We added a line that checks every 10 seconds to make sure the cpu usage of this process is below 5 percent; 3 failed checks results in a restart. We can specify a two-element array for the _times_ option to say that it 3 out of 5 failed attempts results in a restart.

To watch memory usage, we just add one more line:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"

        process.checks :cpu_usage, :every => 10.seconds, :below => 5, :times => 3        
        process.checks :mem_usage, :every => 10.seconds, :below => 100.megabytes, :times => [3,5]
      end
    end
    
We can tell bluepill to give a process some grace time to start/stop/restart before resuming monitoring:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
        process.start_grace_time = 3.seconds
        process.stop_grace_time = 5.seconds
        process.restart_grace_time = 8.seconds

        process.checks :cpu_usage, :every => 10.seconds, :below => 5, :times => 3        
        process.checks :mem_usage, :every => 10.seconds, :below => 100.megabytes, :times => [3,5]
      end
    end

We can group processes by name:

    Bluepill.application("app_name") do |app|
      5.times do |i|
        app.process("process_name_#{i}") do |process|
          process.group = "mongrels"
          process.start_command = "/usr/bin/some_start_command"
          process.pid_file = "/tmp/some_pid_file.pid"
        end
      end
    end

If you want to run the process as someone other than root:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
        process.uid = "deploy"
        process.gid = "deploy"

        process.checks :cpu_usage, :every => 10.seconds, :below => 5, :times => 3        
        process.checks :mem_usage, :every => 10.seconds, :below => 100.megabytes, :times => [3,5]
      end
    end
    
You can also set an app-wide uid/gid:

    Bluepill.application("app_name") do |app|
      app.uid = "deploy"
      app.gid = "deploy"
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
      end
    end
    
To check for flapping:

    process.checks :flapping, :times => 2, :within => 30.seconds, :retry_in => 7.seconds
    
To set the working directory to _cd_ into when starting the command:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
        process.working_dir = "/path/to/some_directory"
      end
    end
    
You can also have an app-wide working directory:


    Bluepill.application("app_name") do |app|
      app.working_dir = "/path/to/some_directory"
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/some_start_command"
        process.pid_file = "/tmp/some_pid_file.pid"
      end
    end
    
Note: We also set the PWD in the environment to the working dir you specify. This is useful for when the working dir is a symlink. Unicorn in particular will cd into the environment variable in PWD when it re-execs to deal with a change in the symlink.


And lastly, to monitor child processes:

    process.monitor_children do |child_process|
      child_process.checks :cpu_usage, :every => 10, :below => 5, :times => 3
      child_process.checks :mem_usage, :every => 10, :below => 100.megabytes, :times => [3, 5]
      
      child_process.stop_command = "kill -QUIT {{PID}}"
    end
    
Note {{PID}} will be substituted for the pid of process in both the stop and restart commands.

### A Note About Output Redirection

While you can specify shell tricks like the following in the start_command of a process:
    
    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "cd /tmp/some_dir && SOME_VAR=1 /usr/bin/some_start_command > /tmp/server.log 2>&1"
        process.pid_file = "/tmp/some_pid_file.pid"
      end
    end
    
We recommend that you _not_ do that and instead use the config options to capture output from your daemons. Like so:

    Bluepill.application("app_name") do |app|
      app.process("process_name") do |process|
        process.start_command = "/usr/bin/env SOME_VAR=1 /usr/bin/some_start_command"
        
        process.working_dir = "/tmp/some_dir"
        process.stdout = process.stderr = "/tmp/server.log"
        
        process.pid_file = "/tmp/some_pid_file.pid"
      end
    end
    
The main benefit of using the config options is that Bluepill will be able to monitor the correct process instead of just watching the shell that spawned your actual server.

### CLI
To start a bluepill process and load a config:

    sudo bluepill load /path/to/production.pill
    
To act on a process or group:

    sudo bluepill <start|stop|restart|unmonitor> <process_or_group_name>
    
To view process statuses:

    sudo bluepill status

To view the log for a process or group:

    sudo bluepill log <process_or_group_name>

To quit bluepill:

    sudo bluepill quit

### Logging  
By default, bluepill uses syslog local6 facility as described in the installation section. But if for any reason you don't want to use syslog, you can use a log file. You can do this by setting the :log\_file option in the config:

    Bluepill.application("app_name", :log_file => "/path/to/bluepill.log") do |app|
      # ...
    end

Keep in mind that you still need to set up log rotation (described in the installation section) to keep the log file from growing huge.
    
### Extra options
You can run bluepill in the foreground:

    Bluepill.application("app_name", :foreground => true) do |app|
      # ...
    end

## Links
Code: [http://github.com/arya/bluepill](http://github.com/arya/bluepill)  
Bugs/Features: [http://github.com/arya/bluepill/issues](http://github.com/arya/bluepill/issues)  
Mailing List: [http://groups.google.com/group/bluepill-rb](http://groups.google.com/group/bluepill-rb)


[gemcutter]: http://gemcutter.org
    