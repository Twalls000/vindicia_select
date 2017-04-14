# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:send_status_email => :environment) do

  StatusUpdateMailer.status_email.deliver_now

end
