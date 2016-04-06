module Europeana
  module OEmbed
    autoload :App, 'europeana/oembed/app'
    autoload :Provider, 'europeana/oembed/provider'
    autoload :Response, 'europeana/oembed/response'
    autoload :Source, 'europeana/oembed/source'

    class << self
      def sources
        @sources ||= []
      end

      def register
        source = Europeana::OEmbed::Source.new
        yield source
        sources << source

        source.urls.each { |url| source.provider << url }
        ::OEmbed::Providers.register(source.provider)
      end

      def response_for(url, format: :json)
        oembed_provider = ::OEmbed::Providers.find(url)
        source = sources.detect { |source| source.provider == oembed_provider }
        fail "No oEmbed source registered for URL #{url}" if source.nil?
        source.response_for(url, format: format)
      end
    end

    Dir[File.expand_path('../oembed/sources/*.rb', __FILE__)].each { |file| require file }
  end
end
