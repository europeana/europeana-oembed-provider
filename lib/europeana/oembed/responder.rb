module Europeana
  module OEmbed
    module Responder
      autoload :Base, 'europeana/oembed/responder/base'
      autoload :CREMCNRS, 'europeana/oembed/responder/cremcnrs'
      autoload :CCMA, 'europeana/oembed/responder/ccma'
      autoload :Ina, 'europeana/oembed/responder/ina'
      autoload :Picturepipe, 'europeana/oembed/responder/picturepipe'
      autoload :Rich, 'europeana/oembed/responder/rich'
      autoload :Video, 'europeana/oembed/responder/video'

      def self.for(provider)
        case provider
        when Europeana::OEmbed::Providers::CCMA
          CCMA
        when Europeana::OEmbed::Providers::CREMCNRS
          CREMCNRS
        when Europeana::OEmbed::Providers::Ina
          Ina
        when Europeana::OEmbed::Providers::Picturepipe
          Picturepipe
        end
      end
    end
  end
end
