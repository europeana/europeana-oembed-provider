# Build and run Europeana oEmbed provider for production use

FROM ruby:2.3.3-alpine

MAINTAINER Europeana Foundation <development@europeana.eu>

ENV RACK_ENV="production"
ENV PORT="80"

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN apk update && \
    apk add --no-cache --virtual .build-deps build-base && \
    echo "gem: --no-document" >> /etc/gemrc && \
    bundle install --deployment --without development:test --jobs=4 --retry=4 && \
    rm -rf vendor/bundle/ruby/2.5.0/bundler/gems/*/.git && \
    rm -rf vendor/bundle/ruby/2.5.0/cache && \
    rm -rf /root/.bundle && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*
#
#
# RUN apt-get update -qq && \
#     apt-get install -y build-essential && \
#     bundle install --without development:test && \
#     rm -rf vendor/bundle/ruby/2.3.0/bundler/gems/*/.git && \
#     rm -rf vendor/bundle/ruby/2.3.0/cache && \
#     rm -rf /root/.bundle && \
#     apt-get remove -y -q --purge build-essential && \
#     apt-get autoremove -y -q && \
#     rm -rf /var/lib/apt/lists/*

# Copy code
COPY . .

EXPOSE 80

ENTRYPOINT ["bundle", "exec", "puma"]
CMD ["-C", "config/puma.rb"]
