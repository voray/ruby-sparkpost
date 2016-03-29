require 'net/http'
require 'uri'
require_relative '../core_extensions/object'
require_relative 'api'
require_relative 'exceptions'

module SparkPost
  class Template < Api
    PATH = '/api/v1/templates'.freeze

    def list
      request(api_url, @api_key, nil, 'GET')
    end
  end
end
