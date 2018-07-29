# frozen_string_literal: true

module Europeana
  module OEmbed
    module Response
      autoload :Base,  'europeana/oembed/response/base'
      autoload :HTML,  'europeana/oembed/response/html'
      autoload :Link,  'europeana/oembed/response/link'
      autoload :Rich,  'europeana/oembed/response/rich'
      autoload :Video, 'europeana/oembed/response/video'

      def self.for(type, data: nil)
        response_type = type.respond_to?(:call) ? type.call(data) : type
        case response_type
        when :rich, :video, :link
          const_get(response_type.to_s.capitalize)
        else
          fail ArgumentError, "Unknown response type \"#{response_type}\""
        end
      end
    end
  end
end
