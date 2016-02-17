# Europeana oEmbed Provider

[![security](https://hakiri.io/github/europeana/europeana-oembed-provider/develop.svg)](https://hakiri.io/github/europeana/europeana-oembed-provider/master) [![Dependency Status](https://gemnasium.com/europeana/europeana-oembed-provider.svg)](https://gemnasium.com/europeana/europeana-oembed-provider)

An aggregate [oEmbed](http://oembed.com/) provider for a variety of embedabble
media players used by Europeana's data partners.

## License

Licensed under the EUPL V.1.1.

For full details, see [LICENSE.md](LICENSE.md).

## Requirements

* Ruby 2.x

## Installation

The Europeana oEmbed Provider is a simple [Sinatra](http://www.sinatrarb.com/)
application.

1. Clone the repo
2. `bundle install`
3. `bundle exec ruby app.rb -s Puma` (or `foreman start` in development
  environments)

## Usage

The application responds to oEmbed requests at its root path. For example:

[http://localhost:3000/?url=http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/](http://localhost:3000/?url=http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/)

Responses are in JSON.

## Supported providers

* [CCMA](http://www.ccma.cat/) videos
* [Ina.fr](http://ina.fr/) videos
* [Picturepipe](http://www.picturepipe.com/) videos
