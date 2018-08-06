# frozen_string_literal: true

require 'dotenv/load' if ENV['RACK_ENV'] != 'production'

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
#   1. Validate parameters, if 'url' is missing or if any of them is invalid,
#      return a HTTP 400. if 'format' is present, check that it matches 'json',
#      otherwise respond with HTTP 501.
#   2. Check the 'url' against one of the supported patterns, otherwise respond
#      with HTTP 404.
#   3. Process the 'url' and obtain the metadata as required. If no metadata was
#      obtained because the record was not found, return HTTP 404.
#   4. Check 'rights_url' (extracted when processing the URL) against one of the
#      supported licenses. If it does not match or no value is indicated respond
#      accordingly.
#   5. Determine the HTML template to be applied based on the 'maxwidth' and
#      'maxheight' HTTP parameters. If neither is specified, return the highest
#      resolution available.
#   6. Apply template and generate HTML. HTML templates to be supplied by
#      Collections scrum team front-end developers.
#   7. Send an HTTP 200 response following the structure.

module Europeana
  module OEmbed
    module Helpers
      class << self
        def handle_response(response)
          response.type = ->(data) { get_type(data) }
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

        # Call the backend and preprocess the rdf data
        def preprocessor(opts, id, media_url = nil)
          opts = check_opts(opts)

          url = "http://data.europeana.eu/item/#{id}"

          graph = RDF::Graph.load(url)

          # puts graph.dump(:ntriples)

          # Proxies
          europeana_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'true').first.subject
          provider_proxy = graph.query(predicate: RDF::Vocab::EDM.europeanaProxy, object: 'false').first.subject

          # Aggregations
          # TODO
          # europeana_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::EDM.EuropeanaAggregation).first.subject
          provider_aggregation = graph.query(predicate: RDF.type, object: RDF::Vocab::ORE.Aggregation).first.subject

          # Title
          title = graph.query(subject: europeana_proxy, predicate: RDF::Vocab::DC11.title).map(&:object).map(&:to_s).first
          if title.nil?
            title = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.title).map(&:object).map(&:to_s).first
          end

          # Description
          description = graph.query(subject: europeana_proxy, predicate: RDF::Vocab::DC11.description).map(&:object).map(&:to_s).first
          if description.nil?
            description = graph.query(subject: provider_proxy, predicate: RDF::Vocab::DC11.description).map(&:object).map(&:to_s).first
          end

          # Author name
          author_name = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.dataProvider).first&.object.to_s

          # Author url
          author_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownAt).first&.object.to_s

          # Provider url
          provider_url = get_provider_url(opts['language'], id)

          # Rights url
          rights_url = get_rights_url(graph, provider_aggregation)
          is_valid_rights = valid_rights(rights_url)

          response = {
            version: ENV['API_PROVIDER_VERSION'] || '[*API_PROVIDER_VERSION*]',
            width: ENV['MAX_WIDTH'] || '[*WIDTH*]',
            height: ENV['MAX_HEIGHT'] || '[*HEIGHT*]',
            provider_name: ENV['API_PROVIDER_NAME'] || '[*API_PROVIDER_NAME*]',
            provider_url: provider_url,

            html: ENV['API_EUROPEANA_SERVICE'] || '[*API_EUROPEANA_SERVICE*]',
            title: title || '',
            description: description || '',
            author_name: author_name || '',
            author_url: author_url || '',
            rights_url: rights_url || ''
          }

          if is_valid_rights
            api_thumbnail_by_url = ENV['API_THUMBNAIL_BY_URI'] ||
                                   'https://www.europeana.eu/api/v2/thumbnail-by-url.json?uri=%<uri>&size=w<width>'
            width = opts['maxwidth'].to_i < 200 ? 200 : 400
            # TODO
            if media_url
              # edm_has_view = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.hasView)
              # edm_has_view.each do |statement|
              #   puts "statement=#{statement.inspect}"
              # end
            end
            thumbnail_url = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.object).first.object.to_s
            thumbnail_by_url = api_thumbnail_by_url.sub('%<uri>', CGI.escape("#{thumbnail_url}&size=w#{width}"))
            response[:thumbnail_url] = thumbnail_by_url || ''
            response[:thumbnail_width] = width
            # TODO
            # response[:thumbnail_height] = '[*THUMBNAIL_HEIGHT*]'
          end

          response
        end

        private

        # Get the type based on the rights_url, if valid => :rich otherwise => :link
        def get_type(data)
          valid_rights(data[:rights_url]) ? :rich : :link
        end

        # Validate the correct options passed with the url: maxwidth, minwidth, format and
        # language.
        def check_opts(opts)
          opts.each do |key, value|
            case key
            when /^maxwidth|maxheight$/ then
              raise "Invalid parameter #{key} '#{value}' must be: integer" unless /^\d+$/.match?(value)
            when /^format$/ then
              formats = %w{json}
              raise "Invalid parameter #{key} '#{value}' must be: #{formats}" unless formats.index(value)
            when /^language$/ then
              languages = %w{bg ca cs da de el en es et fi fr ga hr hu it lt lv mt no nl pl pt ro ru sk sl sv}
              raise "Invalid parameter #{key} '#{value}' must be: #{languages}" unless languages.index(value)
            else
              parameters = %{format language maxwidth maxheight}
              raise "Invalid parameter #{key} must be: #{parameters}"
            end
          end.merge(maxwidth: opts['maxwidth'] || ENV['MAX_WIDTH'], maxheight: opts['maxheight'] ||= ENV['MAX_HEIGHT'])
        end

        # Extract the rights_url from the rdf data
        def get_rights_url(graph, provider_aggregation)
          # Get the URL of the image from "object.aggregations[1].isShownBy", then look for the respective web resource
          # with the following JSON path expression and apply the additional logic below:
          # "object.aggregations[1].webResources[.about={IMAGE_URL}].webResourceEdmRights"
          # If no value exists get the default from: "object.aggregations[1].edmRights"

          # TODO
          edm_is_shown_by = graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.isShownBy).first&.object

          if edm_is_shown_by
            edm_is_shown_by_rights = graph.query(subject: edm_is_shown_by, predicate: RDF::Vocab::EDM.rights).first&.object
          end

          if edm_is_shown_by_rights
            edm_is_shown_by_rights.to_s
          else
            graph.query(subject: provider_aggregation, predicate: RDF::Vocab::EDM.rights).first&.object.to_s
          end
        end

        # Build the provider url using the api_portal, language and id.
        def get_provider_url(lang, id)
          "#{ENV['API_PORTAL']}/#{lang ? lang + '/' : ''}record/#{id}.html"
        end

        # Scan the allowed rights urls and if present return true, otherwise false.
        def valid_rights(url)
          return false if url.nil?
          u = url.sub(%r{^https?://}, '')
          %w{publicdomain/mark/1.0 publicdomain/zero/1.0 licenses/by/1.0 licenses/by-sa/1.0}.each do |s|
            return true if u.start_with?("creativecommons.org/#{s}")
          end
          false
        end
      end
    end
  end
end
