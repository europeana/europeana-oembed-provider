module Europeana
  module OEmbed
    module Response
      autoload :Base, 'europeana/oembed/response/base'
      autoload :HTML, 'europeana/oembed/response/html'
      autoload :Rich, 'europeana/oembed/response/rich'
      autoload :Video, 'europeana/oembed/response/video'

      def self.for(type)
        case type
        when :rich, :video, :europeana
          const_get(type.to_s.capitalize)
        else
          fail ArgumentError, "Unknown response type \"#{type}\""
        end
      end
    end
  end
end
