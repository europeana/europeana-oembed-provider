module Europeana
  module OEmbed
    module Responder
      class Base
        def self.json(url)
          JSON.generate(body_hash(url))
        end
      end
    end
  end
end
