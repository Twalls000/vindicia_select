require 'csv'
class SummaryReport
  include ActionView::Helpers::NumberHelper
  
  def initialize(records,options)
    @records = records
    @range = options.fetch(:range,'')
    @total_captured_count = 0
    @total_all_count = 0
    @total_captured_amount = 0
    @total_all_amount = 0
  end

  def to_csv
    
    CSV.generate do |csv|
      
      inject_header(csv)

      @records.each do |record|
        @total_captured_count += record.captured_count.to_i
        @total_all_count += record.all_count.to_i
        @total_captured_amount += record.captured_amount.to_f
        @total_all_amount += record.all_amount.to_f
        
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

      inject_footer(csv)
    end
  end

  def inject_header csv
    
    date_range = "#{@range.begin} - #{@range.end}"

    csv << [nil,nil,"Summary Report",nil,nil,nil,nil]
    csv << [nil,nil,"Date Range",date_range,nil,nil,nil]
    csv << ["Unit",
            "Total Count",
            "Total Captured",
            "% Captured",
            "Total $",
            "Captured $",
            "% $"]
  end

  def inject_footer csv
    csv << ["Total",
            @total_all_count,
            @total_captured_count,
            number_to_percentage((@total_captured_count.to_f / @total_all_count.to_f)*100, precision: 2),
            number_to_currency(@total_all_amount),
            number_to_currency(@total_captured_amount),
            number_to_percentage((@total_captured_amount.to_f / @total_all_amount.to_f)*100, precision: 2)]
  end

  

end