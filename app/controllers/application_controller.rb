class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_wall
  before_filter :authenticate
  around_filter :set_time_zone

  protected
  def set_time_zone(&block)
    Time.zone = @wall.time_zone if @wall
    yield
  ensure
    Time.zone = nil
  end
  def load_wall
    @wall = Wall.find(params[:wall_id]) if params[:wall_id]
  end

  def authenticate
    return true unless @wall.try(&:locked?)
    return true if session_authenticated?(@wall)
    authenticate_or_request_with_http_basic("#{@wall.name} is locked") do |username, password|
      mark_authenticated(@wall, password == @wall.password)
    end
  end
  def mark_authenticated(wall, result)
    session["wall_#{wall.id}"] = result
  end
  def session_authenticated?(wall)
    session["wall_#{wall.id}"]
  end
end
