require 'json'
require 'oembed'
require 'sinatra'
require 'rack/cors'
require 'europeana/oembed'

module Europeana
  module OEmbed
    ##
    # Sinatra app to respond to oEmbed requests
    class App < Sinatra::Base
      use Rack::Cors do
        allow do
          origins '*'
          resource '/', headers: :any, methods: :get
        end
      end

      get '/' do
        if params.key?('url')
          begin
            body = Europeana::OEmbed.response_for(params['url'])
            [200, { 'Content-Type' => 'application/json' }, [body]]
          rescue StandardError => e
            if e.message =~ /No oEmbed source registered for URL/
              rack_response(404)
            else
              raise e
            end
          end
        else
          # Simple "OK" response at root URL without `url` param
          rack_response(200)
        end
      end

      get '/*' do
        rack_response(404)
      end

      protected

      def rack_response(code)
        [code, { 'Content-Type' => 'text/plain' }, [Rack::Utils::HTTP_STATUS_CODES[code]]]
      end
    end
  end
end
