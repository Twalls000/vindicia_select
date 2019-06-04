class GenerateTripleBalancingReportJob < ActiveJob::Base
  queue_as :default 

  def perform(start_date,end_date)
    type = "Weekly"
    records = DeclinedCreditCardTransaction.where(status: 'processed', created_at: (Date.parse(start_date)..Date.parse(end_date)))
    
    ap "I found #{records.count} records"
	csv = TripleBalancingReport.new(records).to_csv

  end
end
