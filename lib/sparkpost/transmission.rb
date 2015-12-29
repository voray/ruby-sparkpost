require 'net/http'
require 'uri'
require 'http'
require_relative '../core_extensions/object'
require_relative 'request'
require_relative 'exceptions'

module SparkPost
  class Transmission
    include Request

    def initialize(api_key, api_host)
      @api_key = api_key
      @api_host = api_host
    end

    def endpoint
      @api_host.concat('/api/v1/transmissions')
    end

    def send_message(to, from, subject, html_message = nil, **options)
      unless to.is_a?(Array)
        to = [to]
      end

      if html_message.blank? && options[:text_message].blank?
        fail ArgumentError, 'Content missing. Either provide html_message or text_message in options parameter'
      end

      unless is_valid_email?(to) || is_valid_email?(from)
        fail ArgumentError, 'Email is not valid'
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

      request(endpoint, @api_key, options)
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

    def is_valid_email?(email)
      (email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
    end

  end
end

