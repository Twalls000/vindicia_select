# source 'https://rubygems.org'
source 'https://artifactory.gannettdigital.com/artifactory/api/gems/ecom-feature-all-gems/'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.13', '< 0.5'
gem 'ibm_db_odbc', '0.8.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'materialize-sass'

# Project specific tools
gem 'httplog'
gem 'awesome_print'
gem 'gci-simple-encryption', '~> 0.1.3'
gem 'composite_primary_keys'

# Background processing, Cron jobs
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'
gem 'whenever'

# Workflow
gem 'aasm'
# This is the Vindicia API gem. It includes Savon
gem 'vindicia_cash_box_api'

# New Relic
gem 'newrelic_rpm'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug'
  #gem 'sqlite3'
  gem "capistrano", '= 3.6.0'
  gem 'capistrano-bundler', '~> 1.1.1'
  gem 'capistrano-rails'
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'minitest'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring'
end
gem 'simplecov', :group => :test
