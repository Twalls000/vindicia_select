Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 10 # 25 seems too large.
Delayed::Worker.max_run_time = 2.hours
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
