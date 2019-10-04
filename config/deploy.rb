# config valid only for current version of Capistrano
lock "3.11.0"

set :application, "eeefff-org"
set :repo_url, "./_site"

# set :scm, :none_scm
# set :repository, '.'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, ->{fetch :remote_dir}
# set :deploy_via, :copy

# set :exclude_dir, ["./*"]
# set :include_dir, ["_site"]

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# set :revision, ->{run_locally "git log --pretty=format:'%H' -1"}
# desc 'Hakyll integration'
namespace :hakyll do
  desc 'Build the website locally using Hakyll'

  task :build do
    on roles(:all) do
      run_locally do
        execute :stack, 'exec', 'site', '--', 'build'
      end
    end
  end

  # desc 'Print Jekyll deprecation warnings'
  # task :doctor do
  #   on roles(:web) do
  #     within release_path do
  #       execute :jekyll, 'doctor'
  #     end
  #   end
  # end

  after 'deploy:started', 'hakyll:build'
end

namespace :outsourcing_paradise do
  task :force_upload do
    on roles(:all) do
      #
      # JSON
      #
      json = File.read("data/outsourcing-paradise-parasite/erosion-machine-timeline.json").gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))

      upload! StringIO.new(json), "#{current_path}/data/outsourcing-paradise-parasite/erosion-machine-timeline.json"

      #
      # CSS
      #
      upload! "_site/css/erosion-machine-timeline.css", "#{current_path}/css/erosion-machine-timeline.css"
    end
  end


  task :setup_timeline do
    on roles(:all) do
      execute :mkdir, "-p",  "#{release_path}/data/outsourcing-paradise-parasite"

      json = File.read("data/outsourcing-paradise-parasite/erosion-machine-timeline.json").gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))

      upload! StringIO.new(json), "#{release_path}/data/outsourcing-paradise-parasite/erosion-machine-timeline.json"

      puts "OUTSOURCING PARADISE: HOST is #{fetch(:outsourcing_paradise_host_name)}"
    end
  end

  after "deploy:updated", "outsourcing_paradise:setup_timeline"
end

# Override default tasks which are not relevant to a non-rails app.
namespace :deploy do
  task :migrate do
    puts "Skipping migrate."
  end
  task :finalize_update do
    puts "Skipping finalize_update."
  end
  task :start do
    puts "Skipping start."
  end
  task :stop do
    puts "Skipping stop."
  end
  task :restart do
    puts "Skipping restart."
  end
end
