# Use this file to easily define all of your cron jobs.
#
set :output, "/log/#{Rails.env}_cron.log"
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
every 5.minutes do
  rake "process_declined_credit_cards"
end
