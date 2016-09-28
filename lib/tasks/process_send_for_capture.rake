# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:process_send_for_capture => :environment) do

  SendForCapture.process

end
