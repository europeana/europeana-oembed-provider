module Europeana
  module OEmbed
    class Source
      attr_accessor :id, :field

      def <<(url)
        urls << url
      end

      def urls
        @urls ||= []
      end

      def provider
        @provider ||= Provider.new(Provider::ENDPOINT)
      end

      def respond_with
        yield response_config
      end

      def response_config
        @response_config ||= OpenStruct.new
      end

      def response_for(url)
        response_class = Response.for(response_config.type)
        response_class.new(url, self).render
      end

      def id_for(url)
        if id.is_a?(Regexp)
          url.match(id)
        elsif id.respond_to?(:call)
          id.call(url)
        elsif id.nil?
          url
        else
          fail "Unknown id type #{id.class}"
        end
      end
    end
  end
end
