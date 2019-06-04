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

  desc 'generate triple balancing report (for previous week)'
  task(:triple_balancing => :environment) do
    today = Date.today
    #last_week = today - 1.week
    last_week = Date.new(2017,4,17)
    start_date = last_week.beginning_of_week.to_s
    end_date = last_week.end_of_week.to_s
    GenerateTripleBalancingReportJob.new.perform(start_date,end_date)
    #GenerateTripleBalancingReportJob.perform_later(start_date,end_date)
  end
end
