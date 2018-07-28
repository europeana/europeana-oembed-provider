require 'test_helper'
require 'json'

WebMock.disable_net_connect!(allow: %r{\Ahttps?://((data.europeana.eu/item/[^/]+/[^/]+)|((www.)?europeana.eu/api/v2/record/[^/]+/[^/.]+\.jsonld\?wskey=#{ENV['API_KEY']}))\z})

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Europeana::OEmbed::App
  end

  def test_invalid_format_not_supported
    get '/?url=http://data.europeana.eu/item/123/dummy_456&format=invalid'
    assert_equal 501, last_response.status
  end

  def test_data_item_supported_license
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length > 0
    end
  end

  def test_data_item_unsupported_license
    id = '2023008/71022A99_priref_799'
    get '/', url: "http://data.europeana.eu/item/#{id}"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'link', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url rights_url}.each do |attr|
      assert json[attr].to_s.length > 0
    end
    %w{thumbnail_url thumbnail_width}.each do |attr|
      assert_nil json[attr]
    end
  end
end


