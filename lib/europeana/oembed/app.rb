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
      def rack_404
        [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
      end

      get '/' do
        provider = ::OEmbed::Providers.find(params['url'])
        case provider
        when Provider
          responder = Responder.for(provider)
          body = responder.json(params['url'])
          [200, { 'Content-Type' => 'application/json' }, [body]]
        else
          rack_404
        end
      end

      get '/*' do
        rack_404
      end
    end
  end
end
