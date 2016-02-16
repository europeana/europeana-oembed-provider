module Europeana
  module OEmbed
    module Responder
      class Ina < Europeana::OEmbed::Responder::Base
        def self.body_hash(url)
          uri = URI.parse(url)
          id = uri.path.match(%r{/video/([^/]+)/})[1]

          {
            version: '1.0',
            type: 'video',
            width: 620,
            height: 349,
            html: "<iframe width=\"620\" height=\"349\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" scrolling=\"no\" src=\"https://player.ina.fr/player/embed/#{id}/1/1b0bd203fbcd702f9bc9b10ac3d0fc21/620/349/0\"></iframe>"
          }
        end
      end
    end
  end
end
