# config valid only for current version of Capistrano
lock "3.11.0"

set :application, "eeefff-org"
set :repo_url, "./_site"

#
# OP subdir for 2020's edition
#
set :op_2020_scope, "v2/test"

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
    scope = ENV.fetch('SCOPE', false)

    on roles(:all) do
      #
      # JSON
      #
      upload_json! current_path, scope: scope

      #
      # CSS
      #
      upload_css! current_path
    end
  end


  task :setup_timeline do
    on roles(:all) do
      mk_base_dir release_path

      #
      # JSON
      #

      # 2019 - liquid fiction edition
      upload_json! release_path
      # 2020 - garage.digital and eeefff.org
      upload_json! release_path, scope: fetch(:op_2020_scope)

      #
      # CSS
      #

      # 2019 - liquid fiction edition
      upload_css! release_path
      # 2020 - garage.digital and eeefff.org
      do_upload_css_2020! release_path, scope: fetch(:op_2020_scope)

      #
      # JS
      #

      # 2020 - garage.digital and eeefff.org
      do_upload_js_2020! release_path, scope: fetch(:op_2020_scope)

      puts "OUTSOURCING PARADISE: HOST is #{fetch(:outsourcing_paradise_host_name)}"
    end
  end

  after "deploy:updated", "outsourcing_paradise:setup_timeline"

  #
  # assets tasks
  #

  # upload images
  task :force_upload_images do
    scope = ENV.fetch('SCOPE', false)

    on roles(:all) do
      mk_base_dir current_path, scope: scope

      force_upload_dir! "images", current_path, scope: scope
    end
  end

  # TODO: add scope
  task :force_upload_fonts do
    on roles(:all) do
      mk_base_dir current_path

      force_upload_dir! "fonts", current_path
    end
  end

  task :force_upload_videos do
    scope = ENV.fetch('SCOPE', false)

    on roles(:all) do
      mk_base_dir current_path, scope: scope

      force_upload_dir! "videos", current_path, scope: scope
    end
  end

  namespace :v2020 do
    #
    # create v2 symlinks in *current* directory
    #
    task :force_mk_v2_files do
      scope = ENV.fetch('SCOPE', false)

      on roles(:all) do
        # https://dev.eeefff.org/css/erosion-machine-timeline-v2.css
        # https://dev.eeefff.org/js/erosion-machine-timeline-v2.js


        #
        #
        # js
        #
        #
        do_upload_js_2020! current_path, scope: scope

        #
        # JSON
        #
        upload_json! current_path, scope: scope

        #
        # css
        #
        do_upload_css_2020! current_path, scope: scope
      end
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
  def force_upload_dir! dir_name, base_path, scope: false
    s = "data/outsourcing-paradise-parasite/"
    s << scope << "/" if scope
    s << dir_name

    d = "#{base_path}/data/outsourcing-paradise-parasite"
    d << "/" << scope if scope

    upload! s, d, recursive: true
  end

  #
  # upload json to the server
  #
  def upload_json! base_path, scope: false
    s = "data/outsourcing-paradise-parasite/"
    s << scope << "/" if scope
    s << "erosion-machine-timeline.json"

    json = File.read(s).gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name)).gsub(/"EROSION_DELAY"/, fetch(:outsourcing_paradise_erosion_delay).to_s)

    d = "#{base_path}/data/outsourcing-paradise-parasite/"
    d << scope << "/" if scope
    d << "erosion-machine-timeline.json"

    upload! StringIO.new(json), d

    execute :chmod, '644', d
  end

  # TODO: implement scoped
  def upload_css! base_path, scope: false

    css = File.read("_site/css/erosion-machine-timeline.css").gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))
    upload! StringIO.new(css), "#{base_path}/css/erosion-machine-timeline.css"
  end

  #
  # create base dir
  #
  def mk_base_dir base_path, scope: false
    path = "#{base_path}/data/outsourcing-paradise-parasite"
    path << "/" << scope if scope

    execute :mkdir, "-p", path
  end

  #
  #
  # 2020's utils
  #
  #

  #
  # upload modified js files
  #
  def do_upload_js_2020! base_path, scope: false
    #
    # upload prelude
    #
    js = File.read('js/op-erosion-machine-prelude.js').gsub("HOST_NAME", fetch(:outsourcing_paradise_host_name))

    js_path = File.join(base_path, 'js/op-erosion-machine-prelude.js')
    upload! StringIO.new(js), js_path
    execute :chmod, '644', js_path

    # make a link for garage digital
    execute :ln, '-sf', base_path.join('js/op-erosion-machine-prelude.js'), base_path.join('js/erosion-machine-timeline-v2.js')

    # rest of engine's js files
    [ 'js/op-erosion-machine-runtime-main.js',
     'js/op-erosion-machine-vendors-main.js',
     'js/op-erosion-machine-main-chunk.js'].each do |src_path|
      target_path = base_path.join(src_path)
      upload! src_path, target_path
    end
  end

  #
  # upload css
  #
  def do_upload_css_2020! base_path, scope: false
    target_css = base_path.join('css/erosion-machine-timeline-v2.css')
    source_css = base_path.join('css/erosion-machine-timeline.css')
    execute :ln, '-sf', source_css, target_css
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
