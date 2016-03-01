module Europeana
  module OEmbed
    module Responder
      class Base
        class << self
          def json(url)
            instance = new(url)
            JSON.generate(instance.body)
          end

          def requires(*parameters)
            parameters.unshift(:type) unless parameters.include?(:type)

            define_method(:required_parameters) do
              parameters
            end

            parameters.each do |p|
              define_method(p) do
                fail NotImplementedError, "#{self.class.to_s} fails to implement ##{p.to_s}"
              end
            end
          end
        end

        def initialize(url)
          @url = url
        end

        def body
          required_parameters.each_with_object(version: '1.0') do |p, body|
            body[p] = send(p)
          end
        end
      end
    end
  end
end
