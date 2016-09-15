set :stage, :development

role :app, %w{ent-mocdvnmas05}
role :web, %w{ent-mocdvnmas05}
role :db,  %w{ent-mocdvnmas05}

set :keep_releases, 2

set :ssh_options, {
    keys: ['~/.ssh/id_rsa'],
    user: "capuser"
  }

set :deploy_to, '/opt/apps/vindicia-select/'
set :branch, 'master'
set :rails_env, "development"

before "deploy:assets:precompile", :copy_app_config do
  on roles(:app) do
    #execute "cp -fa #{release_path}/config/deploy/development/* #{release_path}/config/"
  end
end

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    on roles(delayed_job_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'bin/delayed_job', args, :restart
        end
      end
    end
  end
end

def args
  fetch(:delayed_job_args, "--queues=fetch_billing_results,create_declined_batches,send_for_capture,n=5")
end
def delayed_job_roles
  fetch(:delayed_job_server_role, :app)
end
# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
