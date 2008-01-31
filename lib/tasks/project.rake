rspec_base = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
require 'spec/rake/spectask'
require 'spec/translator'
require 'rubygems'

spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop

task :noop do
end

namespace :dna do
  namespace :db do
    desc "Migrate down to 0, then back up to current"
    task :cycle => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      ActiveRecord::Migrator.migrate("db/migrate", 0)
      ActiveRecord::Migrator.migrate("db/migrate", version)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    desc "Migrate down one version, then up one version, specifying a version number causes it to go down to that version then back up"
    task :top => :environment do
      current_version = ActiveRecord::Migrator.current_version
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : current_version - 1
      ActiveRecord::Migrator.migrate("db/migrate", version)
      ActiveRecord::Migrator.migrate("db/migrate", current_version)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  desc "migrate down one, up one, then run rake"
  task :go => ["db:top","default"]

  desc "Run this task to send subscription expiration notifications in development - otherwise, run: script/runner -e production PaidSubscription.send_expiration_notifications"
  task :send_expiration_notifications => :environment do
    PaidSubscription.send_expiration_notifications
  end
  namespace :spec do
    desc "Run the spectask with -e option to filter the file. E='spec title', FILE='Filename'"
    Spec::Rake::SpecTask.new(:e => spec_prereq) do |t|
      e = ENV["E"] ? ENV["E"].to_s : "failures.txt"
      f = ENV["FILE"] ? ENV["FILE"].to_s : nil
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\"", "-e \"#{e}\""]
      t.spec_files = FileList[f]
    end
  end
  
  namespace :svn do
    desc "Add new files to subversion"
    task :add_new_files do
       system "svn status | grep '^\?' | awk '{print $2}' | xargs svn add"
    end

    desc "Delete missing files from subversion"
    task :delete_missing_files do
       system "svn status | grep '^\!' | awk '{print $2}' | xargs svn del"
    end

    desc "shortcut for adding new files"
    task :add => [ :add_new_files ]

    desc "shortcut for adding new files"
    task :del => [ :delete_missing_files ]

    desc "Print directories managed by Piston."
    task :pistoned do
      puts Dir['**/.svn/dir-props'].select { |file| File.read(file) =~ /piston/ }.map { |file| file.split('.svn').first }
    end
  end
  
  desc "Get any updates, check for conflicts, run specs, display status and info"
  task :precommit do
    system 'svn up'
    conflicts = `svn st | grep '^C'`
    raise "Conflicts: " << conflicts unless conflicts.empty?
    Rake::Task['spec'].invoke
    Rake::Task['stories'].invoke
    system 'svn info'
    deletes = `svn st | grep '^\!'`
    unadded = `svn st | grep '^\?'`
    system 'svn status'
    puts "Deletes: " << deletes unless deletes.empty?
    puts "Unadded: " << unadded unless unadded.empty?
    
  end
end

namespace :spec do
  task :e => "dna:spec:e"
end

namespace :db do
  task :cycle => "dna:db:cycle"
  task :top => "dna:db:top"  
end

desc "Run all stories"
task :stories do
  system "#{RAILS_ROOT}/script/story"
end

desc "Run the acceptance tests, starting/stopping the selenium server."
task :acceptance => ['acceptance:selenium:start'] do
  begin
    Rake::Task['acceptance:run'].invoke
  ensure
    Rake::Task['acceptance:selenium:stop'].invoke
  end
end
 
namespace :acceptance do
  desc "Run the acceptance tests, assuming the selenium server is running."
  task :run do
    system 'ruby stories/all.rb'
  end
  

  
  namespace :selenium do
    desc "Start the selenium server"
    task :start do
      pid = fork do
        exec 'java -jar lib/selenium-server/selenium-server.jar'
        exit! 127
      end
      File.open SELENIUM_SERVER_PID_FILE, 'w' do |f|
        f.puts pid
      end
      # wait a few seconds to make sure it's finished starting
      sleep 3
    end
 
    desc "Stop the selenium server"
    task :stop do
      if File.exist? SELENIUM_SERVER_PID_FILE
        pid = File.read(SELENIUM_SERVER_PID_FILE).to_i
        Process.kill 'TERM', pid
        FileUtils.rm SELENIUM_SERVER_PID_FILE
      else
        puts "#{SELENIUM_SERVER_PID_FILE} not found"
      end
    end
  end
end
 
private
 
SELENIUM_SERVER_PID_FILE = 'tmp/pids/selenium_server.pid'