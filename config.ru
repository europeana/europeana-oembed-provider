$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'europeana/oembed/app'
run Europeana::OEmbed::App
