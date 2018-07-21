load './lib/europeana/oembed/sources/europeana/helpers.rb'

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

# Params:
#   url       - (mandatory): the URL of the resource to be embedded.
#   format    - (optional): only accepts 'json' as value.
#   maxwidth  - (optional): maximum width of the embedded resource.
#   maxheight - (optional): maximum height of the embedded resource.
#   language  - (optional): language in which the item will be shared.
#
# Processing:
#   1. Validate parameters, if 'url' is missing or if any of them is invalid, return a HTTP 400. if 'format' is
#      present, check that it matches 'json', otherwise respond with HTTP 501.
#   2. Check the 'url' against one of the supported patterns, otherwise respond with HTTP 404.
#   3. Process the 'url' and obtain the metadata as required. If no metadata was obtained because the record was not
#      found, return HTTP 404.
#   4. Check 'rights_url' (extracted when processing the URL) against one of the supported licenses. If it does not
#      match or no value is indicated respond accordingly.
#   5. Determine the HTML template to be applied based on the 'maxwidth' and 'maxheight' HTTP parameters. If neither
#      is specified, return the highest resolution available.
#   6. Apply template and generate HTML. HTML templates to be supplied by Collections scrum team front-end developers.
#   7. Send an HTTP 200 response following the structure.

Europeana::OEmbed.register do |source|

  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.id = lambda { |url| URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)\z})[1] }

  source.api = lambda { |url, opts| api_call(url, opts, URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)\z})[1]) }

  source.respond_with do |response|
    handle_response(response, :rich)
  end
end

