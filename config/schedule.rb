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

#weekly report
every :monday, :at => '12:01 am' do
  rake 'run_summary_report:weekly'
end

#ytd report
every :monday, :at => '12:02 am' do
  rake 'run_summary_report:ytd'
end

#monthly report
every '3 0 7 * *' do # every month on the 7th @12:03am'
  rake 'run_summary_report:monthly'
end

#weekly report
every :monday, :at => '3:00 am' do
  rake 'run_summary_report:triple_balancing_report'
end 
