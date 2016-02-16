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

      ##
      # Provider for ina.fr
      #
      # Examples:
      # * http://www.ina.fr/video/I07337664/
      # * http://www.ina.fr/politique/elections-et-scrutins/video/CAB92011596/liste-daniel-hechter.fr.html#xtor=AL-3
      # * http://www.ina.fr/art-et-culture/arts-du-spectacle/video/AFE86002026/le-president-laval-parle-aux-delegues-du-mouvement-des-prisonniers.fr.html#xtor=AL-3
      # * http://www.ina.fr/video/AFE86003412/les-actualites-francaises-edition-du-27-mai-1954.fr.html#xtor=AL-3
      Ina = ::OEmbed::Provider.new('http://oembed.europeana.eu/')
      Ina << 'http://www.ina.fr/video/*'
      Ina << 'http://www.ina.fr/*/video/*'
      ::OEmbed::Providers.register(Ina)
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
      html: "<iframe src=\"http://www.ccma.cat/video/embed/#{id}/\" allowfullscreen scrolling=\"no\" frameborder=\"0\" width=\"500px\" height=\"281px\"></iframe>"
    }

    [200, { 'Content-Type' => 'application/json' }, [JSON.generate(body)]]

  when Europeana::OEmbed::Providers::Ina
    uri = URI.parse(params['url'])
    id = uri.path.match(%r{/video/([^/]+)/})[1]

    body = {
      version: '1.0',
      type: 'video',
      width: 620,
      height: 349,
      html: "<iframe width=\"620\" height=\"349\" frameborder=\"0\" marginheight=\"0\" marginwidth=\"0\" scrolling=\"no\" src=\"https://player.ina.fr/player/embed/#{id}/1/1b0bd203fbcd702f9bc9b10ac3d0fc21/620/349/0\"></iframe>"
    }

    [200, { 'Content-Type' => 'application/json' }, [JSON.generate(body)]]

  else
    [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
  end

end

get '/*' do
  [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
end
