namespace :run_summary_report do

  desc "perform docker deployment"
  task(:weekly => :environment) do
    date = Date.today - 7.days
    GenerateWeeklySummaryReportJob.perform_later(date.to_s)
  end

  desc "perform docker deployment"
  task(:monthly => :environment) do
    date = Date.today - 7.days
    GenerateMonthlySummaryReportJob.perform_later(date.to_s)
  end

  desc "perform docker deployment"
  task(:ytd => :environment) do
    date = Date.today - 7.days
    GenerateYTDSummaryReportJob.perform_later(date.to_s)
  end
end
