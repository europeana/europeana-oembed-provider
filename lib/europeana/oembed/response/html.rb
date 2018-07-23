module Europeana
  module OEmbed
    module Response
      class HTML
        attr_reader :url, :source

        def self.for(url, source, opts)
          new(url, source, opts).render
        end

        def initialize(url, source, opts)
          @url = url
          @source = source
          @opts = opts
        end

        def render
          if source.api&.respond_to?(:call)
            result = source.api.call(url, @opts)
            result.each { |k, v| source.response_config[k] = v }
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
