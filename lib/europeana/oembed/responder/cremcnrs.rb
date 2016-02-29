module Europeana
  module OEmbed
    module Responder
      class CREMCNRS < Base
        def self.body_hash(url)
          uri = URI.parse(url)
          id = uri.path.match(%r{/items/([^/]+)/})[1]

          {
            version: '1.0',
            type: 'rich',
            width: 361,
            height: 215,
            html: %Q(<iframe width="361" height="215" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://archives.crem-cnrs.fr/archives/items/#{id}/player/346x130/"></iframe>)
          }
        end
      end
    end
  end
end
