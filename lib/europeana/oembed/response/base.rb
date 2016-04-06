require 'rest-client'

module Europeana
  module OEmbed
    module Response
      class Base
        attr_reader :url, :source

        class << self
          def requires(*parameters)
            parameters.unshift(:type) unless parameters.include?(:type)

            define_method(:required_parameters) do
              parameters
            end
          end
        end

        # @param url [URL]
        # @param source [Europeana::OEmbed::Source]
        def initialize(url, source)
          @url = url
          @source = source
        end

        def render(format: :json)
          case format
          when :json
            JSON.generate(body)
          else
            fail "Unsupported format: #{format}"
          end
        end

        # @return [Hash]
        def body
          required_parameters.each_with_object(version: '1.0') do |param, body|
            body[param] = if respond_to?(param)
              send(param)
            elsif source.response_config.respond_to?(param)
              source_param_value = source.response_config.send(param)
              if source_param_value.respond_to? :call
                source_param_value.call(self)
              else
                source_param_value
              end
            else
              fail NotImplementedError, "Source fails to implement #{p.to_s}"
            end
          end
        end

        def html
          @html ||= begin
            case source.response_config.html.builder
            when :http
              http_url = source.response_config.html.url.sub('%{id}', source.id_for(url))
              request_headers = source.response_config.html.request_headers || {}
              response = RestClient.get(http_url, request_headers)
              if source.response_config.html.parser.nil?
                response.body
              else
                source.response_config.html.parser.call(response.body)
              end
            when :iframe
              src = source.response_config.html.src.sub('%{id}', source.id_for(url))
              %Q(<iframe src="#{src}" width="#{source.response_config.width}px" height="#{source.response_config.height}px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe>)
            else
              fail "Unsupported HTML builder #{source.response_config.html.builder}"
            end
          end
        end
      end
    end
  end
end
