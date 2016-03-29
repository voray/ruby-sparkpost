require_relative 'request'

module SparkPost
  class Api
    include SparkPost::Request
    PATH = ''.freeze
    def initialize(api_key, api_host)
      @api_key = api_key
      @api_host = api_host
    end

    def api_url
      @url ||= @api_host.concat(self.class::PATH)
    end

    def send_payload(data = {})
      request(api_url, @api_key, data)
    end
  end
end
