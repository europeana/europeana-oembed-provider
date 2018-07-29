# frozen_string_literal: true

require 'oembed'

module Europeana
  module OEmbed
    class Provider < ::OEmbed::Provider
      ENDPOINT = 'http://oembed.europeana.eu/'
    end
  end
end
