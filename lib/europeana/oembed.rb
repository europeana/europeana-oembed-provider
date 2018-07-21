module Europeana
  module OEmbed
    ##
    # Europeana oEmbed aggregate provider
    autoload :App, 'europeana/oembed/app'
    autoload :Provider, 'europeana/oembed/provider'
    autoload :Response, 'europeana/oembed/response'
    autoload :Source, 'europeana/oembed/source'

    class << self
      # @return [Array]
      def sources
        @sources ||= []
      end

      # @yield [Europeana::OEmbed::Source]
      def register
        source = Europeana::OEmbed::Source.new
        yield source
        sources << source

        source.urls.each { |url| source.provider << url }
        ::OEmbed::Providers.register(source.provider)
      end

      # @param url [String] URL of the resource to oEmbed
      def response_for(url, opts)
        oembed_provider = ::OEmbed::Providers.find(url)
        url_source = sources.detect { |source| source.provider == oembed_provider }
        fail "No oEmbed source registered for URL #{url}" if url_source.nil?
        url_source.response_for(url, opts)
      end
    end

    Dir[File.expand_path('../oembed/sources/**/*.rb', __FILE__)].each { |file| require file }
  end
end
