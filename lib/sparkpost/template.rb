require 'net/http'
require 'uri'
require 'http'
require_relative '../core_extensions/object'
require_relative 'request'
require_relative 'exceptions'

module SparkPost
  class Template
    include Request

    def initialize(api_key, api_host)
      @api_key = api_key
      @api_host = api_host
    end

    def endpoint
      @endpoint ||= @api_host.concat('/api/v1/templates')
    end

    def list
      request(endpoint, @api_key, nil, 'GET')
    end
  end
end
