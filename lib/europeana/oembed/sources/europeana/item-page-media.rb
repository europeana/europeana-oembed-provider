load './lib/europeana/oembed/sources/europeana/helpers.rb'

##
# Provider for europeana.eu media within an item page
#
# Example:
# https://www.europeana.eu/portal/en/record/9200397/BibliographicResource_3000126284212.html?url=http://molcat1.bl.uk/IllImages/Ekta/big/E109/E109547.jpg
#

Europeana::OEmbed.register do |source|
  source.urls << %r{\Ahttps?://(?:www.)?europeana.eu/portal/(?:[a-z]{2}/)?record/([0-9]+/[^/.]+)(?:\.html)?[?]url=(.+)\z}

  source.id = lambda { |url| URI.parse(url).path.match(%r{/record/([^/]+)/})[1] }

  source.preprocessor = lambda { |url, opts| preprocessor(url, opts, URI.parse(url).path.match(%r{/record/([0-9]+/[^/.]+)(?:\.html)?[?]url=(.+)\z})[1]) }

  source.respond_with do |response|
    handle_response(response)
  end
end
