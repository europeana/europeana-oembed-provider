require 'json'
require 'oembed'
require 'sinatra'
require 'europeana/oembed'
require 'europeana/oembed/providers'

module Europeana
  module OEmbed
    ##
    # Sinatra app to respond to oEmbed requests
    class App < Sinatra::Base
      get '/' do
        if params.key?('url')
          provider = ::OEmbed::Providers.find(params['url'])
          case provider
          when Provider
            responder = Responder.for(provider)
            body = responder.json(params['url'])
            [200, { 'Content-Type' => 'application/json' }, [body]]
          else
            rack_response(404)
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
