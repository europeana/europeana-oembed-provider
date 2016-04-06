require 'rest-client'

module Europeana
  module OEmbed
    module Response
      class Base
        attr_reader :url, :source

        class << self
          attr_reader :parameters

          def requires(*parameters)
            add_parameters(:required, *parameters)
          end

          def permits(*parameters)
            add_parameters(:optional, *parameters)
          end

          protected

          def add_parameters(set, *parameters)
            @parameters ||= superclass.ancestors.include?(Base) ? superclass.parameters : {}
            @parameters[set] ||= []
            @parameters[set] += parameters
          end
        end

        requires :version, :type
        permits :title, :author_name, :author_url, :provider_name, :provider_url,
          :cache_age, :thumbnail_url, :thumbnail_width, :thumbnail_height

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
          {}.tap do |body|
            self.class.parameters.each_pair do |set, params|
              params.each do |param|
                param_value = body_param(param, required: (set == :required))
                body[param] = param_value unless param_value.nil?
              end
            end
          end
        end

        def version
          '1.0'
        end

        def html
          @html ||= begin
            case source.response_config.html.builder
            when :http
              html_http
            when :iframe
              html_iframe
            else
              fail "Unsupported HTML builder #{source.response_config.html.builder}"
            end
          end
        end

        protected

        def body_param(param, required:)
          if respond_to?(param)
            send(param)
          elsif source.response_config.respond_to?(param)
            source_param_value = source.response_config.send(param)
            source_param_value.respond_to?(:call) ? source_param_value.call(self) : source_param_value
          elsif required
            fail NotImplementedError, "Source fails to implement #{p}"
          end
        end

        def html_http
          http_url = source.response_config.html.url.sub('%{id}', source.id_for(url))
          request_headers = source.response_config.html.request_headers || {}
          response = RestClient.get(http_url, request_headers)
          if source.response_config.html.parser.nil?
            response.body
          else
            source.response_config.html.parser.call(response.body)
          end
        end

        def html_iframe
          src = source.response_config.html.src.sub('%{id}', source.id_for(url))
          %(<iframe src="#{src}" width="#{source.response_config.width}px" height="#{source.response_config.height}px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe>)
        end
      end
    end
  end
end
