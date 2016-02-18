module Europeana
  module OEmbed
    module Responder
      autoload :Base, 'europeana/oembed/responder/base'
      autoload :CCMA, 'europeana/oembed/responder/ccma'
      autoload :Ina, 'europeana/oembed/responder/ina'
      autoload :Picturepipe, 'europeana/oembed/responder/picturepipe'

      def self.for(provider)
        case provider
        when Europeana::OEmbed::Providers::CCMA
          CCMA
        when Europeana::OEmbed::Providers::Ina
          Ina
        when Europeana::OEmbed::Providers::Picturepipe
          Picturepipe
        end
      end
    end
  end
end