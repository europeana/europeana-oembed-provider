require 'dotenv/load'
require 'json/ld'
require 'rdf'
require 'rdf/vocab'

##
# Helper methods for sources
#

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

def handle_response(response)
  response.type = :api
  response.version = ENV['API_PROVIDER_VERSION'] || '[API_PROVIDER_VERSION]'
  response.width = ENV['MAX_WIDTH'] || '[WIDTH]'
  response.height = ENV['MAX_HEIGHT'] || '[HEIGHT]'
  response.provider_name = ENV['API_PROVIDER_NAME'] || '[API_PROVIDER_NAME]'
  response.provider_url = '[PROVIDER_URL]'

  response.html = ENV['API_EUROPEANA_SERVICE'] || '[API_EUROPEANA_SERVICE]'
  response.title = '[TITLE]'
  response.description = '[DESCRIPTION]'
  response.author_name = '[AUTHOR_NAME]'
  response.author_url = '[AUTHOR_URL]'
  response.rights_url = '[RIGHTS_URL]'
end

def api_call(url, opts, id)
  opts = check_opts(opts)

  graph = RDF::Graph.load(url)

  # puts graph.dump(:ntriples)

  # europeana_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'true').first.subject
  provider_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'false').first.subject

  # europeana_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::EDM.EuropeanaAggregation).first.subject
  provider_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::ORE.Aggregation).first.subject

  title = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.title).map(&:object).map(&:to_s).first
  description = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.description).map(&:object).map(&:to_s).first

  author_name = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.dataProvider).first.object.to_s
  author_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownAt).first.object.to_s

  rights_url = get_rights_url(graph, provider_aggregation)
  is_valid_rights = valid_rights(rights_url)

  provider_url = "#{ENV['API_PORTAL']}/"
  provider_url += "#{opts['language']}/" unless opts['language'].nil?
  provider_url += "record/#{id}.html"

  response = {
    type: is_valid_rights ? :rich : :link,
    version: ENV['API_PROVIDER_VERSION'] || '[*API_PROVIDER_VERSION*]',
    width: ENV['MAX_WIDTH'] || '[*WIDTH*]',
    height: ENV['MAX_HEIGHT'] || '[*HEIGHT*]',
    provider_name: ENV['API_PROVIDER_NAME'] || '[*API_PROVIDER_NAME*]',
    provider_url: provider_url,

    html: ENV['API_EUROPEANA_SERVICE'] || '[*API_EUROPEANA_SERVICE*]',
    title: title || '[*TITLE*]',
    description: description || '[*DESCRIPTION*]',
    author_name: author_name || '[*AUTHOR_NAME*]',
    author_url: author_url || '[*AUTHOR_URL*]',
    rights_url: rights_url || '[*RIGHTS_URL*]'
  }

  if is_valid_rights
    api_thumbnail_by_url = ENV['API_THUMBNAIL_BY_URI'] || 'https://www.europeana.eu/api/v2/thumbnail-by-url.json?uri=%{uri}&size=w%{width}'
    width = opts['maxwidth'].to_i < 200 ? 200 : 400
    thumbnail_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.object).first.object.to_s
    thumbnail_by_url = api_thumbnail_by_url.sub('%{uri}', thumbnail_url).sub('%{width}', width.to_s)
    response[:thumbnail_url] = thumbnail_by_url || ''
    response[:thumbnail_width] = width
    # response[:thumbnail_height] = '[*THUMBNAIL_HEIGHT*]'
  end

  response
end

def check_opts(opts)
  opts.each do |key, value|
    case key
    when /^maxwidth|maxheight$/ then raise "Format '#{value}' not correct, must be a number" unless /^\d+$/.match?(value)
    when /^format$/ then raise "Format '#{value}' not supported, must be 'json'" unless value == 'json'
    when /^language$/ then raise "Language '#{value}' not correct, must be two characters long" unless /^[a-z]{2}$/i.match?(value)
    else raise "Unknown parameter '#{key}', must be 'format', 'maxwidth' or 'maxheight'"
    end
  end.merge(maxwidth: opts['maxwidth'] || ENV['MAX_WIDTH'], maxheight: opts['maxheight'] ||= ENV['MAX_HEIGHT'])
end

def get_rights_url(graph, provider_aggregation)
  # Get the URL of the image from “object.aggregations[1].isShownBy”, then look for the respective web resource
  # with the following JSON path expression and apply the additional logic below:
  # “object.aggregations[1].webResources[.about={IMAGE_URL}].webResourceEdmRights”
  # If no value exists get the default from: “object.aggregations[1].edmRights

  # TODO
  # rights_image_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownBy).first.object.to_s
  # web_resources = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.WebResource)
  # web_resources.each { |web_resource| puts "web_resource='${web_resource.inspect}'" }

  graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first.object.to_s
end

def valid_rights(url)
  u = url.sub(%r{^https?://}, '')
  %w{ publicdomain/mark/1.0 publicdomain/zero/1.0 licenses/by/1.0 licenses/by-sa/1.0 }.each do |s|
    return true if u.start_with?("creativecommons.org/#{s}")
  end
  false
end
