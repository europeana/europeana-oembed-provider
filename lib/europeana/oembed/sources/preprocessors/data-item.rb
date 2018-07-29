# frozen_string_literal: true

require 'europeana/oembed/helpers'

##
# Provider for europeana.eu data item
#
# Examples:
#
# Supported license
# id=9200397/BibliographicResource_3000126284212
# id=2048211/NMA_0043756
#
# Unsupported license
# id=2023008/71022A99_priref_799
#
# Different licenses for the WebResource vs Aggregation
# id=000006/UEDIN_214

Europeana::OEmbed.register do |source|
  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.id = ->(url) { URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)\z})[1] }

  source.preprocessor = lambda do |url, opts|
    id = URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)\z})[1]
    Europeana::OEmbed::Helpers.preprocessor(opts, id)
  end

  source.respond_with do |response|
    Europeana::OEmbed::Helpers.handle_response(response)
  end
end
