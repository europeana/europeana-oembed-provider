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
    response.html = 'https://api.picturepipe.net/api/3.0/playouttoken/%<id>/play'
    response.width = 640
    response.height = 480
    response.provider_name = 'PicturePipe'
    response.provider_url = 'http://www.picturepipe.com/'
  end
end
