##
# Provider for TEL newspapers
#
# Example: http://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/3000059757923
Europeana::OEmbed.register do |source|
  source.urls << 'http://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/*'

  source.respond_with do |response|
    response.type = :rich
    response.width = 960
    response.height = 480
    response.provider_name = 'The Europeana Library'
    response.provider_url = 'http://www.theeuropeanlibrary.org/'
  end
end
