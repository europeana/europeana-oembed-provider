module Europeana
  module OEmbed
    module Response
      module HTML
        autoload :Base, 'europeana/oembed/response/html/base'
        autoload :HTTP, 'europeana/oembed/response/html/http'
        autoload :Iframe, 'europeana/oembed/response/html/iframe'

        def self.for(url, source)
          builder_type = source.response_config.html.builder
          builder = case builder_type
                    when :http
                      HTTP
                    when :iframe
                      Iframe
                    else
                      fail ArgumentError, "Unsupported HTML builder type \"#{builder_type}\""
                    end

          builder.render(url, source)
        end
      end
    end
  end
end
