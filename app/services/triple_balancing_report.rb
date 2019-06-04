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
        
        csv << [
          record.name,
          record.all_count,
          record.captured_count,
          number_to_percentage((record.captured_count.to_f / record.all_count.to_f)*100, precision: 2),
          number_to_currency(record.all_amount),
          number_to_currency(record.captured_amount),
          number_to_percentage((record.captured_amount.to_f / record.all_amount.to_f)*100, precision: 2)
        ]
      end

    end
  end

  def inject_header csv
    
    date_range = "#{@range.begin} - #{@range.end}"

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