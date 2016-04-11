require 'rest-client'

module Europeana
  module OEmbed
    module Response
      module HTML
        class HTTP < Base
          def render
            if parse_response?
              response_parser.call(response.body)
            else
              response.body
            end
          end

          def http_url
            source.response_config.html.url.sub('%{id}', source.id_for(url))
          end

          def request_headers
            source.response_config.html.request_headers || {}
          end

          def response
            @response ||= RestClient.get(http_url, request_headers)
          end

          def parse_response?
            !response_parser.nil?
          end

          def response_parser
            @response_parser ||= source.response_config.html.parser
          end
        end
      end
    end
  end
end
