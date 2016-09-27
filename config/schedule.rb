# Use this file to easily define all of your cron jobs.
#
set :output, "/log/cron.log"
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
every 30.minutes do
  rake "process_declined_credit_cards"
end

every "10 7-17/2 * * *" do
  rake "process_send_for_capture"
end

every "30 7-17/2 * * *" do
  rake "process_fetch_billing_results"
end

every 1.day, :at => '7:30 am' do
  rake "process_failed_billing_results"
end
