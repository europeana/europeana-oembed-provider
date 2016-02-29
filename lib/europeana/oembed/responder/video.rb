module Europeana
  module OEmbed
    module Responder
      class Video < Base
        requires :html, :width, :height

        def type
          'video'
        end
      end
    end
  end
end
