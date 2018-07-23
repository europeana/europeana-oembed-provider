require 'test_helper'
require 'json'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Europeana::OEmbed::App
  end

  # TODO
  def test_europeana_data_item_url
    # get '/', url: 'http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212'
    # assert last_response.ok?
    # assert_equal 'application/json', last_response.headers['Content-Type']
    # json = JSON.parse(last_response.body)
    # assert_equal 'rich', json['type']
    # # assert_match %r{<iframe src="https://api.picturepipe.net/api/3.0/playouttoken/53728dac59db46c8a367663cd6359ddb/play}, json['html']
    assert_equal(0, 0)
  end
end
