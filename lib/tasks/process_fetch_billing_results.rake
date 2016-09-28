# Run rake process_declined_credit_cards
# Run rake process_declined_credit_cards RAILS_ENV=production
# Example "run bundle exec rake process_declined_credit_cards"

task(:process_fetch_billing_results => :environment) do

  FetchBillingResults.process

end
