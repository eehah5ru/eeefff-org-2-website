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

#
#
# OUTSOURCING PARADISE tasks
#
#
namespace :outsourcing_paradise do
  #
  # timeline tasks
  #

  #
  # upload json and css only
  #
  task :force_upload_timeline do
    on roles(:all) do
      #
      # JSON
      #
      upload_json! current_path

      #
      # CSS
      #
      upload_css! current_path
    end
  end


  task :setup_timeline do
    on roles(:all) do
      execute :mkdir, "-p",  "#{release_path}/data/outsourcing-paradise-parasite"


      # JSON
      upload_json! release_path

      # CSS
      upload_css! release_path

      puts "OUTSOURCING PARADISE: HOST is #{fetch(:outsourcing_paradise_host_name)}"
    end
  end

  after "deploy:updated", "outsourcing_paradise:setup_timeline"

  #
  # assets tasks
  #

  # upload images
  task :force_upload_images do
    on roles(:all) do
      force_upload_dir! "images", current_path
    end
  end


  task :force_upload_fonts do
    on roles(:all) do
      force_upload_dir! "fonts", current_path
    end
  end

  task :force_upload_videos do
    on roles(:all) do
      force_upload_dir! "videos", current_path
    end
  end

  #
  #
  # utils
  #
  #

  #
  # force upload dir
  #
  def force_upload_dir! dir_name, base_path
    upload! "data/outsourcing-paradise-parasite/#{dir_name}", "#{base_path}/data/outsourcing-paradise-parasite", recursive: true
  end

  #
  # upload json to the server
  #
  def upload_json! base_path
    json = File.read("data/outsourcing-paradise-parasite/erosion-machine-timeline.json").gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))

    upload! StringIO.new(json), "#{base_path}/data/outsourcing-paradise-parasite/erosion-machine-timeline.json"
  end

  def upload_css! base_path
    css = File.read("_site/css/erosion-machine-timeline.css").gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))
    upload! StringIO.new(css), "#{base_path}/css/erosion-machine-timeline.css"
  end
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
