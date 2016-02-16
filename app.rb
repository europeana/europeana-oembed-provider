$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'json'
require 'oembed'
require 'sinatra'
require 'europeana/oembed'
require 'europeana/oembed/providers'

def rack_404
  [404, [Rack::Utils::HTTP_STATUS_CODES[404]]]
end

get '/' do
  provider = OEmbed::Providers.find(params['url'])
  case provider
  when Europeana::OEmbed::Provider
    responder = Europeana::OEmbed::Responder.for(provider)
    body = responder.json(params['url'])
    [200, { 'Content-Type' => 'application/json' }, [body]]
  else
    rack_404
  end
end

get '/*' do
  rack_404
end
