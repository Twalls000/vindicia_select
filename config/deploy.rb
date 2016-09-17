# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'vindicia-select'
set :repo_url, 'https://deployer-gannett:gann3tt!@bitbucket.org/gannett_it/vindicia_select.git'

# Setup SCM as git
set :scm, :git
# set :scm_verbose, true
set :scm_user, "deployer-gannett" # The server's user for deploys
set :scm_password, "gann3tt!"
# set :use_sudo, false
set :local_scm_command, "git"
set :scm_command, "/usr/local/bin/git"

# Linux deploy to
set :user, "capuser"
# set :use_sudo, false
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
set :rvm_type, :system
set :default_env, { 'PATH' => '/opt/ruby216/bin:$PATH' }
set :default_shell, '/bin/bash -l'
set :format, :pretty
set :log_level, :debug
set :pty, true
set :git_ssl_no_verify, true

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

set :whenever_environment, ->{ fetch(:rails_env) }
set :whenever_command, "bundle exec whenever"
#set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  after 'deploy:publishing', 'deploy:restart'
  desc 'Provision env before assets:precompile'
  task :fix_bug_env do
    set :rails_env, (fetch(:rails_env) || fetch(:stage))
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end

  after :finishing, 'deploy:cleanup'

end
task :set_umask do
  on roles(:all) do |host|
    execute "umask 0002"
  end
end
task :set_database_yml do
  on roles(:all) do
    execute "cp #{fetch(:release_path)}/config/database.yml.#{fetch(:stage)} " +
      "#{fetch(:release_path)}/config/database.yml"
  end
end
before "deploy:starting", "set_umask"
before 'deploy:updated', 'set_database_yml'
