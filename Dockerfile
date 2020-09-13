FROM ruby:2.6.3-alpine AS build-env

ARG RAILS_ROOT=/usr/src/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ARG COMMIT_HASH

ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
ENV GEM_HOME="$RAILS_ROOT/vendor/bundle/ruby/2.6.0"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN mkdir $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN apk update && apk upgrade && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

COPY Gemfile package.json ./
RUN bundle install -j4 --retry 3 --path=vendor/bundle \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf vendor/bundle/ruby/2.6.0/cache/*.gem \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.o" -delete
RUN yarn install --check-files

COPY . .

RUN echo $COMMIT_HASH > public/commit.txt

############### Build step done ###############
FROM ruby:2.6.3-alpine
LABEL maintainer="Martin Tomas <martintomas.it@gmail.com>"

ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata postgresql-client nodejs bash yarn"

ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
ENV GEM_HOME="$RAILS_ROOT/vendor/bundle/ruby/2.6.0"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

WORKDIR $RAILS_ROOT

RUN apk update && apk upgrade && apk add --update --no-cache $PACKAGES

COPY --from=build-env $RAILS_ROOT $RAILS_ROOT

ENTRYPOINT ["./entrypoint.sh"]
CMD ["start-server"]
