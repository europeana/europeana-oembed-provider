ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'

require 'coveralls'
Coveralls.wear!

require File.expand_path '../../app.rb', __FILE__
