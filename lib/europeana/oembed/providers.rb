# @todo move these into their own Gem for reuse with ruby-oembed
module Europeana
  module OEmbed
    module Providers
      ##
      # Provider for ccma.cat
      #
      # Example: http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/
      CCMA = Provider.new('http://oembed.europeana.eu/')
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
      Ina = Provider.new('http://oembed.europeana.eu/')
      Ina << 'http://www.ina.fr/video/*'
      Ina << 'http://www.ina.fr/*/video/*'
      ::OEmbed::Providers.register(Ina)

      ##
      # Provider for picturepipe.net
      #
      # Example: http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=53728dac59db46c8a367663cd6359ddb
      Picturepipe = Provider.new('http://oembed.europeana.eu/')
      Picturepipe << 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=*'
      ::OEmbed::Providers.register(Picturepipe)
    end
  end
end
