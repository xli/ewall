require 'net/http'
require 'net/https'

class MingleWall < ActiveRecord::Base
  belongs_to :wall
  attr_accessible :login, :password, :url

  def pull
    uri = if self.url =~ /^http/
      URI(self.url)
    else
      URI("http://#{self.url}")
    end
    ssl = uri.scheme == 'https'
    Net::HTTP.start(uri.host, uri.port, :use_ssl => ssl, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth login, password
      response = http.request request # Net::HTTPResponse object
      response.body
    end
  rescue Errno::ECONNREFUSED
    raise "Connection refused. Please verify the mingle wall url and login, password, and make sure Mingle server's Basic Authetication is turned on"
  end
end
