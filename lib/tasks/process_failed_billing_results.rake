# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:process_failed_billing_results => :environment) do

  FailedBillingResults.process

end
