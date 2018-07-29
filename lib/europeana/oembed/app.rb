# frozen_string_literal: true

require 'json'
require 'oembed'
require 'sinatra'
require 'europeana/oembed'

module Europeana
  module OEmbed
    ##
    # Sinatra app to respond to oEmbed requests
    class App < Sinatra::Base
      get '/healthcheck' do
        [200, { 'Content-Type' => 'application/json' }, ['OK']]
      end

      get '/' do
        if params.key?('url')
          begin
            url = params.delete('url')
            body = Europeana::OEmbed.response_for(url, params)
            [200, { 'Content-Type' => 'application/json' }, [body]]
          rescue StandardError => e
            if e.message.match?(/No oEmbed source registered for URL/)
              rack_response(404)
            elsif e.message.match?(/^Invalid parameter/)
              rack_response(400)
            elsif e.message.match?(/^Format '(.*?)' not supported, must be 'json'$/)
              rack_response(501)
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
