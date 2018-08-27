namespace :run_summary_report do

  desc "generate weekly summary report"
  task(:weekly => :environment) do
    date = Date.today - 7.days
    GenerateWeeklySummaryReportJob.perform_later(date.to_s)
  end

  desc "generate monthly summary report"
  task(:monthly => :environment) do
    date = Date.today - 7.days
    GenerateMonthlySummaryReportJob.perform_later(date.to_s)
  end

  desc "generate TYD summary report"
  task(:ytd => :environment) do
    date = Date.today - 7.days
    GenerateYtdSummaryReportJob.perform_later(date.to_s)
  end
end
