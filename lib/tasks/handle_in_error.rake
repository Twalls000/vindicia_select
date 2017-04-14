# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:handle_in_error => :environment) do

  HandleInError.process

end
