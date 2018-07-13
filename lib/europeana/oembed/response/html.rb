module Europeana
  module OEmbed
    module Response
      class HTML
        attr_reader :url, :source

        def self.for(url, source)
          new(url, source).render
        end

        def initialize(url, source)
          @url = url
          @source = source
        end

        def render
          if source.api
            result = source.api.call(url)
            source.response_config.title = result[:title]
            source.response_config.description = result[:description]
            source.response_config.author_name = result[:author_name]
            source.response_config.author_url = result[:author_url]
            source.response_config.provider_name = result[:provider_name]
            source.response_config.provider_url = result[:provider_url]
          end
          '<iframe ' + attributes.join(' ') + '></iframe>'
        end

        def attributes
          attribute_pairs.map { |k, v| %(#{k}="#{v}") }
        end

        def attribute_pairs
          {
            src: src_attr,
            width: width_attr,
            height: height_attr,
            frameborder: 0,
            marginwidth: 0,
            marginheight: 0,
            scrolling: 'no'
          }
        end

        def src_attr
          if source.response_config.html.nil?
            url
          else
            source.response_config.html.sub('%{id}', source.id_for(url))
          end
        end

        def width_attr
          "#{source.response_config.width}px"
        end

        def height_attr
          "#{source.response_config.height}px"
        end
      end
    end
  end
end
