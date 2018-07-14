require 'json/ld'
require 'rdf'
require 'rdf/vocab'

##
# Provider for europeana.eu data item
#
# Example:
# http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212

Europeana::OEmbed.register do |source|

  def valid_rights_url(url)
    u = url.sub(%r{^https?://},'')
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
    begin
      web_resources = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.WebResource)
    rescue NoMethodError => e
      puts "ERROR: web_resource, e => #{e.inspect}"
    rescue Exception => e
      puts "ERROR: web_resources e => #{e.inspect}"
    end

    web_resources.each { |web_resource| puts "web_resource='${web_resource.inspect}'" }

    rights_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first.object.to_s

    return valid_rights_url(rights_url) ? rights_url : nil
  end

  def call_api(url)

    id = get_id(url)

    begin

    end
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

    rights_url = get_rights_url(graph, provider_aggregation)

    provider_url = "#{ENV['API_PORTAL']}/#{id}.html"

    thumbnail_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.object)
    if thumbnail_url
      thumbnail_url = thumbnail_url.first.to_triple.to_a[2]
    end

    return {
        title: title || '',
        description: description || '',
        author_name: author_name || '',
        author_url: author_url || '',
        provider_url: provider_url || '',
        rights_url: rights_url || '',
        thumbnail_url: thumbnail_url || ''
    }
  end

  source.urls << %r{\Ahttp://data.europeana.eu/item/[0-9]+/[^/]+\z}

  source.api = lambda {|url| call_api(url)}
  source.id = lambda {|url| get_id(url)}

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

