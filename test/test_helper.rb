ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'
require 'coveralls'
require 'simplecov'

if Coveralls.will_run?.nil?
  SimpleCov.start # Generate SimpleCov report during local testing
else
  Coveralls.wear! # Submit Coveralls report in CI env
end

require 'europeana/oembed'
