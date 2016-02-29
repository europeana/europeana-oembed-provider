module Europeana
  module OEmbed
    module Responder
      class CCMA < Base
        def self.body_hash(url)
          uri = URI.parse(url)
          id = uri.path.split('/')[-1]

          {
            version: '1.0',
            type: 'video',
            width: 500,
            height: 281,
            html: "<iframe src=\"http://www.ccma.cat/video/embed/#{id}/\" allowfullscreen scrolling=\"no\" frameborder=\"0\" width=\"500px\" height=\"281px\"></iframe>"
          }
        end
      end
    end
  end
end
