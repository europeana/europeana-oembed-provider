module Europeana
  module OEmbed
    module Response
      module HTML
        class Iframe < Base
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
            source.response_config.html.src.sub('%{id}', source.id_for(url))
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
end
