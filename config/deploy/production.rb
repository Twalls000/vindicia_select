set :stage, :production

role :app, %w{ent-pocapnmas26}
role :web, %w{ent-pocapnmas26}
role :db,  %w{ent-pocapnmas26}

set :keep_releases, 2
set :user_id, ask('Deploy User:', nil)

set :ssh_options, {
    keys: %w(~/.ssh/id_rsa),
    user: fetch(:user_id)
  }

set :deploy_to, '/var/apps/vindicia-select/'
set :branch, ask('the branch:', "master?")
set :default_env, {path: "/opt/ruby2110/bin/:$PATH"}
set :rails_env, 'production'
set :linked_files, %w(config/database.yml config/secrets.yml)

before "deploy:assets:precompile", :copy_app_config do
  on roles(:app) do
    execute "cp -fa #{release_path}/config/deploy/production/* #{release_path}/config/"
  end
end

# Delayed jobs for this environment.
set :delayed_job_pools, { 'failed_billing_results' => 1,
  'create_declined_batches' => 1, 'fetch_billing_results' => 3,
  'send_for_capture' => 3 }
set :delayed_job_pid_dir, '/tmp'
