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
                :cache_age, :thumbnail_url, :thumbnail_width, :thumbnail_height, :rights_url

        # @param url [URL]
        # @param source [Europeana::OEmbed::Source]
        def initialize(url, source)
          @url = url
          @source = source
        end

        def render
          JSON.generate(body)
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

        ##
        # oEmbed version
        #
        # @return [String]
        def version
          '1.0'
        end

        # @return [String]
        def html
          @html ||= HTML.for(url, source)
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
      end
    end
  end
end
