source 'https://rubygems.org'

gem 'puma'
gem 'rake'
gem 'rest-client'
gem 'ruby-oembed'
gem 'sinatra'

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
  gem 'webmock'
end
