module SparkPost
  class DeliveryException < Exception
    attr_reader :service_message, :service_description, :service_code

    def initialize(message)
      errors = if message.is_a?(Hash)
                 message
               else
                 [*message].first
               end

      if errors.respond_to?(:fetch)
        @service_message     = errors['message']
        @service_description = errors['description']
        @service_code        = errors['code']
      end

      super(message)
    end
  end
end
