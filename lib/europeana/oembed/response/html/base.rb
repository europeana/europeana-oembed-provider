module Europeana
  module OEmbed
    module Response
      module HTML
        class Base
          attr_reader :url, :source

          def self.render(url, source)
            new(url, source).render
          end

          def initialize(url, source)
            @url = url
            @source = source
          end

          def render
            fail "#render needs to be implemented in subclass"
          end
        end
      end
    end
  end
end
