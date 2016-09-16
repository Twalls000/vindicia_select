set :output, "/log/#{Rails.env}_cron.log"

# Run every 5 minutes between 8AM and 5PM
every 1.day, at: (8...17).map { |hour| (0..55).map { |minute| "#{hour}:#{minute.to_s.rjust(2, "0")}" if minute % 5 == 0 } }.flatten.compact do
  DeclinedBatches.process
end
