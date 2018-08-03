# Europeana oEmbed Provider

[![Build Status](https://travis-ci.org/europeana/europeana-oembed-provider.svg?branch=develop)](https://travis-ci.org/europeana/europeana-oembed-provider) [![Coverage Status](https://coveralls.io/repos/europeana/europeana-oembed-provider/badge.svg?branch=develop&service=github)](https://coveralls.io/github/europeana/europeana-oembed-provider?branch=develop) [![security](https://hakiri.io/github/europeana/europeana-oembed-provider/develop.svg)](https://hakiri.io/github/europeana/europeana-oembed-provider/develop) [![Dependency Status](https://gemnasium.com/europeana/europeana-oembed-provider.svg)](https://gemnasium.com/europeana/europeana-oembed-provider)

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

1. `git clone https://github.com/europeana/europeana-oembed-provider.git`
2. `bundle install`
3. `bundle exec ruby app.rb -s Puma` (or `foreman start` in development environments)

## Usage

The application responds to oEmbed requests at its root path. For example:

[http://localhost:3000/?url=http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/](http://localhost:3000/?url=http://www.ccma.cat/tv3/alacarta/programa/titol/video/955989/)

Use port `5000` if started with foreman.

Responses are in JSON format, for example using the request above:

```
{"version":"1.0","type":"video","html":"<iframe src=\"http://www.ccma.cat/video/embed/955989/\" width=\"500px\" height=\"281px\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\" scrolling=\"no\"></iframe>","width":500,"height":281,"provider_name":"CCMA","provider_url":"http://www.ccma.cat/"}
```

## Supported providers

| Provider | oEmbed type |
| -------- | ----------- |
| [CCMA](http://www.ccma.cat/) | video |
| [crem-cnrs.fr](http://crem-cnrs.fr) | rich |
| [Ina.fr](http://ina.fr/) | video |
| [Picturepipe](http://www.picturepipe.com/) | video |
| [The European Library](http://www.theeuropeanlibrary.org/) | rich |
| [Europeana](https://www.europeana.eu/) | rich |

## References

* [oEmbed Specification](https://oembed.com/)
* [JSON for Linking Data](https://json-ld.org/)
* [RDF.rb](https://github.com/ruby-rdf/rdf)
* [json-ld.rb](https://github.com/ruby-rdf/json-ld)
* [jsonpath.rb](https://github.com/joshbuddy/jsonpath)
