# frozen_string_literal: true

require 'test_helper'
require 'json'

WebMock.disable_net_connect!(allow: %r{\Ahttps?://((data.europeana.eu/item)|((www.)?europeana.eu/api/v2/record))})

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Europeana::OEmbed::App
  end

  def test_invalid_format
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}", format: 'invalid'
    assert_equal 501, last_response.status
  end

  def test_invalid_language
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}", language: 'invalid'
    assert_equal 501, last_response.status
  end

  def test_invalid_maxwidth
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}", maxwidth: 'invalid'
    assert_equal 501, last_response.status
  end

  def test_invalid_maxheight
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}", maxheight: 'invalid'
    assert_equal 501, last_response.status
  end

  def test_invalid_parameter
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "http://data.europeana.eu/item/#{id}", invalid: 'value'
    assert_equal 501, last_response.status
  end

  def test_data_item_license_ok
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
      assert json[attr].to_s.length.positive?
    end
  end

  # TODO
  def test_data_item_license_more
    assert true
  end

  # TODO: Still fails when run with all tests, for some reason succeeds when run alone.
  def test_data_item_license_nok
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
      assert json[attr].to_s.length.positive?
    end
    %w{thumbnail_url thumbnail_width}.each do |attr|
      assert_nil json[attr]
    end
  end

  def test_item_page
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "https://www.europeana.eu/portal/record/#{id}.html"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  def test_item_page_language
    id = '9200397/BibliographicResource_3000126284212'
    lang = 'en'
    get '/', url: "https://www.europeana.eu/portal/#{lang}/record/#{id}.html"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  def test_item_page_media
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "https://www.europeana.eu/portal/record/#{id}.html?url=http://molcat1.bl.uk/IllImages/Ekta/big/E109/E109547.jpg"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  def test_item_page_media_language
    id = '9200397/BibliographicResource_3000126284212'
    lang = 'en'
    get '/', url: "https://www.europeana.eu/portal/#{lang}/record/#{id}.html?url=http://molcat1.bl.uk/IllImages/Ekta/big/E109/E109547.jpg"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]+"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  # TODO
  def test_item_page_media_has_view
    assert true
  end
end
