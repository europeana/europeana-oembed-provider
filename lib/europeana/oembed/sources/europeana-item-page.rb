##
# Provider for europeana.eu item page
#
# Examples:
# https://www.europeana.eu/portal/en/record/9200397/BibliographicResource_3000126284212.html
# https://www.europeana.eu/portal/record/9200397/BibliographicResource_3000126284212.html

Europeana::OEmbed.register do |source|
  source.urls << %r{\Ahttps?://(?:www.)?europeana.eu/portal/(?:[a-z]{2}/)?record/([0-9]+)/([^/]+)(?:\.html)?\z}

  source.id = lambda { |url| URI.parse(url).path.match(%r{/record/([^/]+)/})[1] }

  source.respond_with do |response|
    response.type = :rich
    response.version = '1.0'
  end
end
