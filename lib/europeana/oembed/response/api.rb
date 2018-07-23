module Europeana
  module OEmbed
    module Response
      class Api < Base
        requires :html, :width, :height

        def type
          'api'
        end
      end
    end
  end
end
