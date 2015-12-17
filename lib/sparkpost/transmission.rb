require 'net/http'
require 'uri'
require 'http'
require_relative '../core_extensions/object'
require_relative './request'
require_relative './exceptions'

module SparkPost
  class Transmission
    include Request

    def initialize(api_key = nil)
      @api_key = (api_key || ENV['SPARKPOST_API_KEY']).to_s
      if @api_key.blank?
        fail ArgumentError, 'No API key provided. Either provide api_key with constructor or set SPARKPOST_API_KEY environment variable'
      end
    end

    def endpoint
      API_HOST.concat('/api/v1/transmissions')
    end

    def transmit(to, from, subject, html_message = nil, **options)
      #todo add validations for to, from
      unless to.is_a?(Array)
        to = [to]
      end

      if html_message.blank? && options[:text_message].blank?
        fail ArgumentError, 'Content missing. Either provide html_message or text_message in options parameter'
      end

      options.merge!(
          {
              recipients: prepare_recipients(to),
              content: {
                  from: from,
                  subject: subject,
                  text: options['text_message'],
                  html: html_message
              },
              options: {}
          }
      )

      request(endpoint, options)
    end

    private
    def prepare_recipients(recipients)
      recipients.map do |recipient|
        {
            address: {
                email: recipient
            }
        }
      end
    end

  end
end

