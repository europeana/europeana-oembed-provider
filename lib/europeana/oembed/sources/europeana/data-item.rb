require 'json/ld'
require 'rdf'
require 'rdf/vocab'

##
# Provider for europeana.eu data item
#
# Example:
# http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212

Europeana::OEmbed.register do |source|

  def get_id(url)
    URI.parse(url).path.match(%r{/item/([0-9]+/[^/]+)})[1]
  end

  def call_api(url)

    id = get_id(url)

    graph = RDF::Graph.load(url)

    puts graph.dump(:ntriples)

    # europeana_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'true').first.subject
    provider_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'false').first.subject

    # europeana_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::EDM.EuropeanaAggregation).first.subject
    provider_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::ORE.Aggregation).first.subject

    title = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.title).map(&:object).map(&:to_s).first
    description = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.description).map(&:object).map(&:to_s).first

    author_name = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.dataProvider).first.object.to_s
    author_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownAt).first.object.to_s

    rights_default_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first.object.to_s
    rights_image_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownBy).first.object.to_s
    rights_url = rights_default_url

    provider_url = "#{ENV['API_PORTAL']}/#{id}.html"

    return {
      title: title,
      description: description,
      author_name: author_name,
      author_url: author_url,
      provider_url: provider_url,
      rights_url: rights_url
    }
  end

  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.api = lambda { |url| call_api(url) }
  source.id = lambda { |url| get_id(url) }

  source.respond_with do |response|
    response.type = :rich
    response.version = '1.0'
    response.width = ENV['MAX_WIDTH']
    response.height = ENV['MAX_HEIGHT']
    response.provider_name = 'Europeana'
    response.provider_url = '[PROVIDER_URL]'

    response.html = ENV['API_EUROPEANA_SERVICE']
    response.title = '[TITLE]'
    response.description = '[DESCRIPTION]'
    response.author_name = '[AUTHOR_NAME]'
    response.author_url = '[AUTHOR_URL]'
    response.rights_url = '[RIGHTS_URL]'
    response.thumbnail_url = '[THUMBNAIL_URL]'
    response.thumbnail_width = 200
    # response.thumbnail_height = ?
  end
end

