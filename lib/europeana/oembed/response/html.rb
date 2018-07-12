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
            if source.field
              fields = source.field.call(url)
              puts fields.inspect
              source.response_config.title = fields[:title]
            else
              source.response_config.html.sub('%{id}', source.id_for(url))
            end
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
