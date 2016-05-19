module Europeana
  module OEmbed
    module Response
      class Rich < Base
        requires :html, :width, :height

        def type
          'rich'
        end
      end
    end
  end
end
