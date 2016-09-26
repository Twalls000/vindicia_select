# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:process_declined_credit_cards => :environment) do

  DeclinedBatches.process

end
