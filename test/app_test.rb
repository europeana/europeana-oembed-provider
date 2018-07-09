require 'test_helper'
require 'json'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Europeana::OEmbed::App
  end

  def test_root_without_params
    get '/'
    assert last_response.ok?
    assert_equal 'text/plain', last_response.headers['Content-Type']
    assert_equal 'OK', last_response.body
  end

  def test_unknown_url
    get '/', url: 'http://www.example.com/'
    assert last_response.not_found?
    assert_equal 'text/plain', last_response.headers['Content-Type']
    assert_equal 'Not Found', last_response.body
  end

  def test_ccma_url
    get '/', url: 'http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/'
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'video', json['type']
    assert_match %r{<iframe src="http://www.ccma.cat/video/embed/955989/"}, json['html']
  end

  def test_cremcnrs_url
    get '/', url: 'http://archives.crem-cnrs.fr/archives/items/9798/'
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'rich', json['type']
    assert_match %r{<iframe src="http://archives.crem-cnrs.fr/archives/items/9798/player/346x130/}, json['html']
  end

  def test_ina_url
    get '/', url: 'http://www.ina.fr/politique/elections-et-scrutins/video/CAB92011596/liste-daniel-hechter.fr.html#xtor=AL-3'
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'video', json['type']
    assert_match %r{<iframe src="https://player.ina.fr/player/embed/CAB92011596/}, json['html']
  end

  def test_picturepipe_url
    get '/', url: 'http://api.picturepipe.net/api/html/widgets/public/playout_cloudfront?token=53728dac59db46c8a367663cd6359ddb'
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'video', json['type']
    assert_match %r{<iframe src="https://api.picturepipe.net/api/3.0/playouttoken/53728dac59db46c8a367663cd6359ddb/play}, json['html']
  end

  def test_europeana_data_item_url
    get '/', url: 'http://data.europeana.eu/item/9200397/BibliographicResource_3000126284212'
    assert last_response.ok?
    assert_equal 'application/json', last_response.headers['Content-Type']
    json = JSON.parse(last_response.body)
    assert_equal 'rich', json['type']
    # assert_match %r{<iframe src="https://api.picturepipe.net/api/3.0/playouttoken/53728dac59db46c8a367663cd6359ddb/play}, json['html']
  end
end
