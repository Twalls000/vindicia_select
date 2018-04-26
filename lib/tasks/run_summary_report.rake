task(:run_weekly_summary_report => :environment) do

  GenerateSummaryReportJob.perform_later(DateRange.new.weekly_range)

end
