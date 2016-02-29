module Europeana
  module OEmbed
    module Responder
      class CCMA < Video
        def html
          uri = URI.parse(@url)
          id = uri.path.split('/')[-1]
          %Q(<iframe src="http://www.ccma.cat/video/embed/#{id}/" allowfullscreen ) +
            %Q(scrolling="no" frameborder="0" width="500px" height="281px"></iframe>)
        end

        def width
          500
        end

        def height
          281
        end
      end
    end
  end
end
