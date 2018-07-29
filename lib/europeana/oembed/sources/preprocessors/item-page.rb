# frozen_string_literal: true

require 'europeana/oembed/helpers'

##
# Provider for europeana.eu item page
#
# Examples:
# https://www.europeana.eu/portal/en/record/9200397/BibliographicResource_3000126284212.html
# https://www.europeana.eu/portal/nl/record/9200397/BibliographicResource_3000126284212
# https://www.europeana.eu/portal/record/9200397/BibliographicResource_3000126284212.html
# https://www.europeana.eu/portal/record/9200397/BibliographicResource_3000126284212

Europeana::OEmbed.register do |source|
  source.urls << %r{\Ahttps?://(?:www.)?europeana.eu/portal/(?:[a-z]{2}/)?record/([0-9]+/[^/.]+)(?:\.html)?\z}

  source.id = ->(url) { URI.parse(url).path.match(%r{/record/([0-9]+/[^/.]+)(?:\.html)?\z})[1] }

  source.preprocessor = lambda do |url, opts|
    id = URI.parse(url).path.match(%r{/record/([0-9]+/[^/.]+)(?:\.html)?\z})[1]
    Europeana::OEmbed::Helpers.preprocessor(opts, id)
  end

  source.respond_with do |response|
    Europeana::OEmbed::Helpers.handle_response(response)
  end
end
