require 'dotenv/load'
require 'json/ld'
require 'rdf'
require 'rdf/vocab'

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

  def valid_rights(url)
    u = url.sub(%r{^https?://}, '')
    allowed_urls = %w{
      creativecommons.org/publicdomain/mark/1.0
      creativecommons.org/publicdomain/zero/1.0
      creativecommons.org/licenses/by/1.0
      creativecommons.org/licenses/by-sa/1.0
    }
    allowed_urls.each do |allowed_url|
      return true if u.start_with?(allowed_url)
    end
    false
  end

  def get_id(url)
    URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)})[1]
  end

  def get_rights_url(graph, provider_aggregation)
    # Get the URL of the image from “object.aggregations[1].isShownBy”, then look for the respective web resource
    # with the following JSON path expression and apply the additional logic below:
    # “object.aggregations[1].webResources[.about={IMAGE_URL}].webResourceEdmRights”
    # If no value exists get the default from: “object.aggregations[1].edmRights
    #
    rights_image_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownBy).first.object.to_s
    web_resources = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.WebResource)
    web_resources.each { |web_resource| puts "web_resource='${web_resource.inspect}'" }

    graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first.object.to_s
  end

  def check_opts(opts)
    ex_name = "Invalid parameter"
    opts.each do |key, value|
      case key
      when /^maxwidth|maxheight$/
        raise "#{ex_name}: format '#{value}' not supported, must be 'json'" unless /^\d+$/.match?(value)
      when /^format$/
        raise "#{ex_name}: format '#{value}' not supported, must be 'json'" unless value == "json"
      else
        raise "#{ex_name}: unknown parameter '#{key}', must be 'format', 'maxwidth' or 'maxheight'"
      end
    end

    opts['maxwidth'] ||= ENV['MAX_WIDTH']
    opts['maxheight'] ||= ENV['MAX_HEIGHT']

    opts
  end

  def get_response(url, opts)

    opts = check_opts(opts)

    id = get_id(url)

    graph = RDF::Graph.load(url)

    # puts graph.dump(:ntriples)

    europeana_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'true').first.subject
    provider_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'false').first.subject

    europeana_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::EDM.EuropeanaAggregation).first.subject
    provider_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::ORE.Aggregation).first.subject

    title = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.title).map(&:object).map(&:to_s).first
    description = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.description).map(&:object).map(&:to_s).first

    author_name = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.dataProvider).first.object.to_s
    author_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownAt).first.object.to_s

    rights_url = get_rights_url(graph, provider_aggregation)
    is_valid_rights = valid_rights(rights_url)

    response = {
        type: is_valid_rights ? :rich : :link,
        version: '1.0',
        attributes: {
            width: ENV['MAX_WIDTH'] || '[*MAX_WIDTH*]',
            height: ENV['MAX_HEIGHT'] || '[*MAX_HEIGHT*]',
            provider_name: ENV['API_PROVIDER_NAME'] || '[*API_PROVIDER_NAME*]',
            provider_url: "#{ENV['API_PROVIDER_NAME']}/#{id}.html",

            html: ENV['API_EUROPEANA_SERVICE'] || '[*API_EUROPEANA_SERVICE*]',
            title: title || '',
            description: description || '',
            author_name: author_name || '',
            author_url: author_url || '',
            rights_url: rights_url || ''
        }
    }

    if is_valid_rights
      api_thumbnail_by_url = ENV['API_THUMBNAIL_BY_URI'] || 'https://www.europeana.eu/api/v2/thumbnail-by-url.json?uri=%{uri}&size=w%{width}'
      width = opts['maxwidth'].to_i < 200 ? 200 : 400
      thumbnail_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.object).first.object.to_s
      thumbnail_by_url = api_thumbnail_by_url.sub('%{uri}', thumbnail_url).sub('%{width}', width.to_s)
      response[:attributes][:thumbnail_url] = thumbnail_by_url || ''
      response[:attributes][:thumbnail_width] = width
      # response[:attributes][:thumbnail_height] = '[*THUMBNAIL_HEIGHT*]'
    else
      # TODO: type needs to be changed to link.
    end

    response
  end

  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.id = lambda {|url| get_id(url)}

  source.api = lambda {|url, opts| get_response(url, opts)}

  source.respond_with do |response|
    # response.type = :europeana
    response.type = :rich
    # response.version = '1.0'
    # response.width = ENV['MAX_WIDTH'] || '[WIDTH]'
    # response.height = ENV['MAX_HEIGHT'] || '[HEIGHT]'
    # response.provider_name = 'Europeana'
    # response.provider_url = '[PROVIDER_URL]'
    #
    # response.html = ENV['API_EUROPEANA_SERVICE'] || '[HTML]'
    # response.title = '[TITLE]'
    # response.description = '[DESCRIPTION]'
    # response.author_name = '[AUTHOR_NAME]'
    # response.author_url = '[AUTHOR_URL]'
    # response.rights_url = '[RIGHTS_URL]'
    # response.thumbnail_url = '[THUMBNAIL_URL]'
    # response.thumbnail_width = '[THUMBNAIL_WIDTH]'
    # response.thumbnail_height = '[THUMBNAIL_HEIGHT]'
  end
end

##
# Provider for europeana.eu media within an item page
#
# Example:
# https://www.europeana.eu/portal/en/record/9200397/BibliographicResource_3000126284212.html?url=http://molcat1.bl.uk/IllImages/Ekta/big/E109/E109547.jpg
#
# Europeana::OEmbed.register do |source|
#   source.urls << %r{\Ahttps?://(?:www.)?europeana.eu/portal/(?:[a-z]{2}/)?record/([0-9]+)/([^/]+)(?:\.html)?[?]url=(.+)\z}
#
#   source.id = lambda { |url| URI.parse(url).path.match(%r{/record/([^/]+)/})[1] }
#
#   source.respond_with do |response|
#     response.type = :rich
#     response.version = '1.0'
#   end
# end

##
# Provider for europeana.eu item page
#
# Examples:
# https://www.europeana.eu/portal/en/record/9200397/BibliographicResource_3000126284212.html
# https://www.europeana.eu/portal/record/9200397/BibliographicResource_3000126284212.html

# Europeana::OEmbed.register do |source|
#   source.urls << %r{\Ahttps?://(?:www.)?europeana.eu/portal/(?:[a-z]{2}/)?record/([0-9]+)/([^/]+)(?:\.html)?\z}
#
#   source.id = lambda { |url| URI.parse(url).path.match(%r{/record/([^/]+)/})[1] }
#
#   source.respond_with do |response|
#     response.type = :rich
#     response.version = '1.0'
#   end
# end
