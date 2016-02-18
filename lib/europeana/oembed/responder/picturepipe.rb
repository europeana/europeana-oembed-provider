require 'rest-client'

module Europeana
  module OEmbed
    module Responder
      class Picturepipe < Europeana::OEmbed::Responder::Base
        def self.body_hash(url)
          uri = URI.parse(url)
          token = Rack::Utils.parse_query(uri.query)['token']
          player_url = "https://api.picturepipe.net/api/3.0/playouttoken/#{token}/play?format=json"
          response = RestClient.get(player_url, accept: :json)

          html = JSON.parse(response.body)['html'].strip
          width = html.match(/width: (\d+)/)[1]
          height = html.match(/height: (\d+)/)[1]

          {
            version: '1.0',
            type: 'video',
            width: width,
            height: height,
            html: html
          }
        end
      end
    end
  end
end
