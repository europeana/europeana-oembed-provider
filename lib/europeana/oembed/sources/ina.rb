##
# Provider for ina.fr
#
# Examples:
# * http://www.ina.fr/video/I07337664/
# * http://www.ina.fr/politique/elections-et-scrutins/video/CAB92011596/liste-daniel-hechter.fr.html#xtor=AL-3
# * http://www.ina.fr/art-et-culture/arts-du-spectacle/video/AFE86002026/le-president-laval-parle-aux-delegues-du-mouvement-des-prisonniers.fr.html#xtor=AL-3
# * http://www.ina.fr/video/AFE86003412/les-actualites-francaises-edition-du-27-mai-1954.fr.html#xtor=AL-3
Europeana::OEmbed.register do |source|
  source.urls << 'http://www.ina.fr/video/*'
  source.urls << 'http://www.ina.fr/*/video/*'

  source.id = lambda { |url| URI.parse(url).path.match(%r{/video/([^/]+)/})[1] }

  source.respond_with do |response|
    response.type = :video
    response.html = 'https://player.ina.fr/player/embed/%{id}/1/1b0bd203fbcd702f9bc9b10ac3d0fc21/620/349/0'
    response.width = 620
    response.height = 349
    response.provider_name = 'Ina.fr'
    response.provider_url = 'http://www.ina.fr/'
  end
end
