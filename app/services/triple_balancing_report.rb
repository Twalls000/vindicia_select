require 'csv'
class TripleBalancingReport
  include ActionView::Helpers::NumberHelper

  def initialize(records)
    @records = records
  end

  def to_csv
    
    CSV.generate do |csv|
      
      inject_header(csv)

      @records.each do |record|
        csv << [record.amount,
                record.merchant_transaction_id,
                record.select_transaction_id,
                record.pub_code,
                record.account_number, 
                record.gci_unit,
                record.account_holder_name,
                record.batch_id,
                record.batch_date]        
      end
    end
  end

  def inject_header csv
    
    #date_range = "#{@range.begin} - #{@range.end}"

    csv << [nil,nil,"Triple Balancing Report",nil,nil,nil,nil]
    
    csv << ["Amount", 
            "Merchant Transaction ID", 
            "select_transaction_id", 
            "pub_code",
            "account_number", 
            "gci_unit",
            "account_holder_name",
            "batch_id",
            "batch_date"]
  end

end