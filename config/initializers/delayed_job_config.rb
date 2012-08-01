Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 6
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 20.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = !Rails.env.test?
