# Use this file to easily define all of your cron jobs.
#

set :output, File.join(Whenever.path, "log", "cron.log")
env :PATH, ENV['PATH']
every 5.minutes do
  rake "process_declined_credit_cards"
end
