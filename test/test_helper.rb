ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'

require 'coveralls'
Coveralls.wear!

require 'europeana/oembed'
