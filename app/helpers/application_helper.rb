module ApplicationHelper
  def format_time(time)
    time.strftime('%l %p, %b %e %z')
  end

  def full_time_format(time)
    time.strftime("%d %b %Y %I:%M%p %z")
  end
end
