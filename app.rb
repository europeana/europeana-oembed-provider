require 'json'
require 'oembed'
require 'rest-client'
require 'sinatra'

# @todo move these into their own Gem for reuse with ruby-oembed
module Europeana
  module OEmbed
    module Providers
      ##
      # Provider for picturepipe.net
      #
      # Example: http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=53728dac59db46c8a367663cd6359ddb
      Picturepipe = ::OEmbed::Provider.new('http://oembed.europeana.eu/')
      Picturepipe << 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
      ::OEmbed::Providers.register(Picturepipe)

      ##
      # Provider for ccma.cat
      #
      # Example: http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/
      CCMA = ::OEmbed::Provider.new('http://oembed.europeana.eu/')
      CCMA << 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/*/'
      ::OEmbed::Providers.register(CCMA)
    end
  end
end

get '/' do

  case OEmbed::Providers.find(params['url'])
  when Europeana::OEmbed::Providers::Picturepipe
    uri = URI.parse(params['url'])
    token = Rack::Utils.parse_query(uri.query)['token']
    player_url = "https://api.picturepipe.net/api/3.0/playouttoken/#{token}/play?format=json"
    response = RestClient.get(player_url)
    html = JSON.parse(response.body)['html'].strip
    width = html.match(/width: (\d+)/)[1]
    height = html.match(/height: (\d+)/)[1]

    body = {
      version: '1.0',
      type: 'video',
      width: width,
      height: height,
      html: html
    }

    [200, { 'Content-Type' => 'application/json' }, [JSON.generate(body)]]

  when Europeana::OEmbed::Providers::CCMA
    uri = URI.parse(params['url'])
    id = uri.path.split('/')[-1]

    body = {
      version: '1.0',
      type: 'video',
      width: 500,
      height: 281,
      html: "<iframe src=\"http://www.ccma.cat/video/embed/955989/\" allowfullscreen scrolling=\"no\" frameborder=\"0\" width=\"500px\" height=\"281px\"></iframe>"
    }

    [200, { 'Content-Type' => 'application/json' }, [JSON.generate(body)]]

  else
    [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
  end

end

get '/*' do
  [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
end
