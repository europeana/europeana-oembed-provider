module Europeana
  module OEmbed
    module Responder
      class Ina < Video
        def html
          uri = URI.parse(@url)
          id = uri.path.match(%r{/video/([^/]+)/})[1]
          %Q(<iframe width="620" height="349" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ) +
            %Q(src="https://player.ina.fr/player/embed/#{id}/1/1b0bd203fbcd702f9bc9b10ac3d0fc21/620/349/0"></iframe>)
        end

        def width
          620
        end

        def height
          349
        end
      end
    end
  end
end
