#!/usr/bin/env ruby

require "net/http"
require "uri"

class Connection

  PATH = "/api/v1/transmissions"
  ENDPOINT = "http://private-14a2c-msystransmissionspubliccloudv1.apiary-mock.com"

  def initialize
    uri = URI.parse(ENDPOINT)
    @http = Net::HTTP.new(uri.host, uri.port)
    puts "Host: #{uri.host}" # private-14a2c-msystransmissionspubliccloudv1.apiary-mock.com
    puts "Port: #{uri.port}" # 80
  end

  def all
    request :all
  end

  def find(params)
    request :find, params
  end

  def post(path, params)
    request :post, path, params
  end

  private

  def request(method, params = nil)
    case method
    when :all
      request = Net::HTTP::Get.new(PATH)
    when :find
      request = Net::HTTP::Get.new("#{PATH}/#{params}")
    else
      request = Net::HTTP::Post.new(PATH)
      request.set_form_data(params)
    end

    response = @http.request(request)
    format_response(response)
  end

  def format_response(response)
    case response.code.to_i
    when 400
      puts "The specified Transmission ID does not exist"
    when 200
      puts "Response Code: #{response.code}"
      puts "Response Body: #{response.body}"
    when 500
      raise StandarError, "Received bad response from Transmission API: #{response.code}"
    end
  end

end


transmission = Connection.new
transmission.all
transmission.find("11713562166689858")
