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
                  text: options.delete(:text_message),
                  html: html_message
              },
              options: {}
          }
      )
      
      if options[:attachments].present? 
        options[:content][:attachments] = options.delete(:attachments)
      end

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

  end
end

