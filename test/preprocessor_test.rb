# frozen_string_literal: true

# rubocop:disable Style/RegexpLiteral
require 'test_helper'
require 'json'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    WebMock.stub_request(:get, 'http://data.europeana.eu/item/000002/_UEDIN_214').
      with(
        headers: {
          'Accept': %r{^application/ld\+json, application/x\-ld\+json},
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent': 'Ruby'
        }
      ).
      to_return(status: 200, body: get_body('000002/_UEDIN_214'),
                headers: { 'Content-Type': 'application/ld+json' })

    WebMock.stub_request(:get, 'http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212').
      with(
        headers: {
          'Accept': %r{^application/ld\+json, application/x\-ld\+json},
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent': 'Ruby'
        }
      ).
      to_return(status: 200, body: get_body('9200397/BibliographicResource_3000126284212'),
                headers: { 'Content-Type': 'application/ld+json' })

    WebMock.stub_request(:get, 'http://data.europeana.eu/item/2023008/71022A99_priref_799').
      with(
        headers: {
          'Accept': %r{^application/ld\+json, application/x\-ld\+json},
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent': 'Ruby'
        }
      ).
      to_return(status: 200, body: get_body('2023008/71022A99_priref_799'),
                headers: { 'Content-Type': 'application/ld+json' })

    WebMock.stub_request(:get, 'http://data.europeana.eu/item/08623/883').
      with(
        headers: {
          'Accept': %r{^application/ld\+json, application/x\-ld\+json},
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent': 'Ruby'
          }
      ).
      to_return(status: 200, body: get_body('08623/883'),
                headers: { 'Content-Type': 'application/ld+json' })
  end

  def get_body(id)
    File.read("./test/fixtures/#{id.sub(/\//, '_')}.json").strip
  end

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
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  def test_data_item_license_nok
    id = '2023008/71022A99_priref_799'
    get '/', url: "http://data.europeana.eu/item/#{id}"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'link', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
    %w{thumbnail_url thumbnail_width}.each do |attr|
      # TODO: Still fails when run with all tests, for some reason succeeds when run alone.
      assert_nil json[attr]
    end
  end

  # TODO
  def test_data_item_license_more
    assert true
  end

  # Language EN found (first)
  def test_data_item_language_en
    id = '08623/883'
    lang = 'en'
    get '/', url: "http://data.europeana.eu/item/#{id}", language: lang
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'English title', json['title']
    assert_equal 'English description', json['description']
  end

  # Language FR found (second)
  def test_data_item_language_fr
    id = '08623/883'
    lang = 'fr'
    get '/', url: "http://data.europeana.eu/item/#{id}", language: lang
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'French title', json['title']
    assert_equal 'French description', json['description']
  end

  # Language DE not found, choose EN (first)
  def test_data_item_language_de
    id = '08623/883'
    lang = 'de'
    get '/', url: "http://data.europeana.eu/item/#{id}", language: lang
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'English title', json['title']
    assert_equal 'English description', json['description']
  end

  # No language given, choose EN (first)
  def test_data_item_language_none
    id = '08623/883'
    get '/', url: "http://data.europeana.eu/item/#{id}"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'English title', json['title']
    assert_equal 'English description', json['description']
  end

  def test_item_page
    id = '9200397/BibliographicResource_3000126284212'
    get '/', url: "https://www.europeana.eu/portal/record/#{id}.html"
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal '1.0', json['version']
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
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
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
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
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
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
    assert_match %r{<iframe src="[^"]+#{id}[^"]*"}, json['html']
    assert_equal 'Europeana', json['provider_name']
    assert_match %r{https://www.europeana.eu/portal/record/#{id}.html}, json['provider_url']
    %w{width height title description author_name author_url thumbnail_url thumbnail_width rights_url}.each do |attr|
      assert json[attr].to_s.length.positive?
    end
  end

  # TODO
  def test_item_page_media_has_view
    assert true
  end
end
# rubocop:enable Style/RegexpLiteral
