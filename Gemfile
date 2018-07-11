source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '~> 5.2.0'

gem 'puma'
gem 'rake'
gem 'ruby-oembed'
gem 'sinatra'

# Needed for the Europeana oEmbed service
gem 'rest-client'
gem 'rdf'
gem 'json-ld'
gem 'jsonpath'

group :development, :test do
  gem 'dotenv', '~> 2.0'
  gem 'rubocop', '0.35.1', require: false # only update when Hound does
end

group :development do
  gem 'foreman'
end

group :test do
  gem 'coveralls', require: false
  gem 'minitest'
  gem 'rack-test', require: 'rack/test'
  gem 'simplecov', require: false
  gem 'webmock'
end
