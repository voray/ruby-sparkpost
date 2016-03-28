require 'net/http'
require 'json'

require_relative 'version'
require_relative 'exceptions'

module SparkPost
  module Request
    def request(url, api_key, data, verb = 'POST')
      uri = URI.parse(url)
      http = configure_http(uri)
      headers = {
        'User-Agent' => 'ruby-sparkpost/' + VERSION,
        'Content-Type' => 'application/json',
        'Authorization' => api_key
      }
      req = configure_request(uri, headers, data, verb)
      process_response(http.request(req))
    end

    def configure_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end

    def configure_request(uri, headers, data, verb)
      req = case verb
            when 'GET'
              Net::HTTP::Get.new(uri.path, headers)
            when 'PUT'
              Net::HTTP::Put.new(uri.path, headers)
            when 'DELETE'
              Net::HTTP::Delete.new(uri.path)
            else
              Net::HTTP::Post.new(uri.path, headers)
            end
      if data.present?
        req.body = JSON.generate(data)
      end
      req
    end

    def process_response(response)
      response = JSON.parse(response.body)
      if response['errors']
        raise SparkPost::DeliveryException, response['errors']
      else
        response['results']
      end
    end

    module_function :request, :configure_http, :configure_request,
                    :process_response
  end
end
