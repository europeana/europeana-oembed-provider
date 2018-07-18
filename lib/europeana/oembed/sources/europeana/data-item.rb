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
    web_resources.each {|web_resource| puts "web_resource='${web_resource.inspect}'"}

    graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first.object.to_s
  end

  def get_response(url)

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

    thumbnail_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.object).first.object.to_s

    response = {
      type: is_valid_rights ? :rich : :link,
      version: '1.0',
      width: ENV['MAX_WIDTH'] || '[*WIDTH*]',
      height: ENV['MAX_HEIGHT'] || '[*HEIGHT*]',
      provider_name: ENV['API_PROVIDER_NAME'] || 'Europeana',
      provider_url: "#{ENV['API_PORTAL']}/#{id}.html",

      html: ENV['API_EUROPEANA_SERVICE'] || '[*HTML*]',
      title: title || '',
      description: description || '',
      author_name: author_name || '',
      author_url: author_url || '',
      rights_url: rights_url || ''
    }

    if is_valid_rights
      response[:thumbnail_url] = thumbnail_url || ''
      response[:thumbnail_width] = '[*THUMBNAIL_WIDTH*]'
      response[:thumbnail_height] = '[*THUMBNAIL_HEIGHT*]'
    end

    response
  end

  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.id = lambda {|url| get_id(url)}

  source.api = lambda {|url| get_response(url)}

  source.respond_with do |response|
    response.type = :rich
    response.version = '1.0'
    response.width = ENV['MAX_WIDTH'] || '[WIDTH]'
    response.height = ENV['MAX_HEIGHT'] || '[HEIGHT]'
    response.provider_name = 'Europeana'
    response.provider_url = '[PROVIDER_URL]'

    response.html = ENV['API_EUROPEANA_SERVICE'] || '[HTML]'
    response.title = '[TITLE]'
    response.description = '[DESCRIPTION]'
    response.author_name = '[AUTHOR_NAME]'
    response.author_url = '[AUTHOR_URL]'
    response.rights_url = '[RIGHTS_URL]'
    response.thumbnail_url = '[THUMBNAIL_URL]'
    response.thumbnail_width = '[THUMBNAIL_WIDTH]'
    response.thumbnail_height = '[THUMBNAIL_HEIGHT]'
  end
end

