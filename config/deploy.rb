# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "ocill"
set :repo_url, 'git@bitbucket.org:johnathb/ocill.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ocilllrc/ocill'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml', 'public/.htaccess')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

set :branch, "umdeploy"
set :use_sudo, true

set :rails_env, "production"

set :deploy_via, :remote_cache
set :copy_exclude, [ '.git' ]

set :tmp_dir, "/home/ocilllrc/tmp"

server "ocill.lrc.lsa.umich.edu", user: 'ocilllrc', roles: [:app, :web, :db], :primary => true

set :ping_url, "https://ocill.lrc.lsa.umich.edu/"

set :passenger_restart_with_touch, true

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
  desc 'Warm up the application by pinging it, so enduser wont have to wait'
  task :ping do
    on roles(:app), in: :sequence, wait: 5 do
      execute "curl -s -D - #{fetch(:ping_url)} -o /dev/null"
    end
  end
 
  after :restart, :ping

end