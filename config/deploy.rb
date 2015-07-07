# config valid only for Capistrano 3.1

lock '3.2.1'

set :application, 'project-secretservice'

set :repo_url, 'git@git.assembla.com:project-secretservice.server.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/project-secretservice.server'

set :user, 'root'
set :use_sudo, false
set :rails_env,'production'
set :deploy_via,:remote_cache


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

after "deploy", "deploy:database"
after "deploy:database", "apache:restart"
after "apache:restart", "swagger:symlinkui"
after "swagger:symlinkui", "swagger:rebuild"
after "swagger:rebuild", "permissions:set_images"

