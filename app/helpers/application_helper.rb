module ApplicationHelper
  def format_time(time)
    time.localtime.strftime('%l %p, %b %e')
  end
end
