##
# Helper methods for sources
#

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

