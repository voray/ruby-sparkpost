require 'net/http'
require 'uri'
require_relative '../core_extensions/object'
require_relative 'request'

module SparkPost
  class SuppressionList
    include Request

    def initialize(api_key, api_host)
      @api_key       = api_key
      @api_host      = api_host
      @base_endpoint = "#{@api_host}/api/v1/suppression-list".freeze
    end

    def search(from: nil, to: nil, types: nil, sources: nil, limit: nil)
      params = {
        to: to,
        from: from,
        types: array_params(types),
        sources: array_params(sources),
        limit: limit
      }.reject { |_, v| v.nil? }

      url = endpoint(nil, params)
      request(url, @api_key, {}, 'GET')
    end

    private

    def array_params(param)
      param.is_a?(Array) ? param.join(',') : param
    end
  end
end
