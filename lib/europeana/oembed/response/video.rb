# frozen_string_literal: true

module Europeana
  module OEmbed
    module Response
      class Video < Base
        requires :html, :width, :height

        def type
          'video'
        end
      end
    end
  end
end
