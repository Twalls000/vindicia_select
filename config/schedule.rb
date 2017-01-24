# Use this file to easily define all of your cron jobs.
#
set :output, File.join("#{Whenever.path}/../../shared", "log", "vindicia_cron.log")
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
every 1.day, :at => '12:15 am' do
  rake "process_declined_credit_cards"
end

every "5,15,30,45,55 6-11 * * *" do
  rake "process_send_for_capture"
end

every "5,15,30,45,55 6-11 * * *" do
  rake "process_fetch_billing_results"
end

every 1.day, :at => '7:30 am' do
  rake "process_failed_billing_results"
end

every 1.day, :at => '9:00 pm' do
  rake "handle_in_error"
end

every 1.day, :at => '5:00 am' do
  rake "send_status_email"
end
