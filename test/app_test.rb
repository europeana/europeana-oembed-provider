require 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_without_params
    get '/'
    assert last_response.not_found?
    assert_equal 'Not Found', last_response.body
  end
end
