require 'rest-client'

module Europeana
  module OEmbed
    module Responder
      class Picturepipe < Video
        def html
          @html ||= get_html_from_picturepipe_api
        end

        def width
          @width ||= html.match(/width: (\d+)/)[1]
        end

        def height
          @height ||= html.match(/height: (\d+)/)[1]
        end

        private

        def get_html_from_picturepipe_api
          response = RestClient.get(player_url, accept: :json)
          JSON.parse(response.body)['html'].strip
        end

        def player_url
          uri = URI.parse(@url)
          token = Rack::Utils.parse_query(uri.query)['token']
          "https://api.picturepipe.net/api/3.0/playouttoken/#{token}/play?format=json"
        end
      end
    end
  end
end
