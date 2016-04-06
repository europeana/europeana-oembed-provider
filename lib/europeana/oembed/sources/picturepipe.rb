##
# Provider for picturepipe.net
#
# Example: http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=53728dac59db46c8a367663cd6359ddb
Europeana::OEmbed.register do |source|
  source.urls << 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
  source.urls << 'https://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'

  source.id = lambda { |url| Rack::Utils.parse_query(URI.parse(url).query)['token'] }

  source.respond_with do |response|
    response.type = :video
    response.html.builder = :http
    response.html.request_headers = { accept: :json }
    response.html.url = 'https://api.picturepipe.net/api/3.0/playouttoken/%{id}/play?format=json'
    response.html.parser = lambda { |http| JSON.parse(http)['html'].strip }
    response.width = lambda { |response| response.html.match(/width: (\d+)/)[1] }
    response.height = lambda { |response| response.html.match(/height: (\d+)/)[1] }
  end
end
