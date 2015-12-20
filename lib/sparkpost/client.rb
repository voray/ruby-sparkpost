module SparkPost
    class Client
        attr_reader :transmission
        
        def initialize(api_key = nil, api_host = 'https://api.sparkpost.com')
            @api_key = (api_key || ENV['SPARKPOST_API_KEY']).to_s
            @api_host = (api_host || ENV['SPARKPOST_API_HOST']).to_s

            if @api_key.blank?
                fail ArgumentError, 'No API key is provided. Either provide api_key with constructor or set SPARKPOST_API_KEY environment variable'
            end


            if @api_host.blank?
                fail ArgumentError, 'No API host is provided. Either provide api_host with constructor or set SPARKPOST_API_HOST environment variable'
            end
        end

        def transmission
            @transmission ||= Transmission.new(@api_key, @api_host)
        end
    end
end