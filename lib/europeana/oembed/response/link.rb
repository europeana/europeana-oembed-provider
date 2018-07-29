# frozen_string_literal: true

module Europeana
  module OEmbed
    module Response
      class Link < Base
        requires :html, :width, :height

        def type
          'link'
        end
      end
    end
  end
end
