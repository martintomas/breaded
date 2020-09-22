FROM ruby:2.6.3-alpine AS build-env

ARG RAILS_ROOT=/usr/src/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"

ENV RAILS_ENV=development
ENV NODE_ENV=development

RUN mkdir $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN apk update && apk upgrade && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

COPY Gemfile ./
RUN bundle install
# Remove unneeded files (cached *.gem, *.o, *.c)
RUN rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY package.json ./
RUN yarn install --check-files

############### Finalize build ###############
FROM ruby:2.6.3-alpine
LABEL maintainer="Martin Tomas <martintomas.it@gmail.com>"

ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata postgresql-client nodejs bash yarn"
ARG COMMIT_HASH

WORKDIR $RAILS_ROOT

RUN apk update && apk upgrade && apk add --update --no-cache $PACKAGES

RUN adduser -D rails_user
USER rails_user

COPY --chown=rails_user . .
COPY --chown=rails_user --from=build-env /usr/local/bundle/ /usr/local/bundle/
COPY --chown=rails_user --from=build-env $RAILS_ROOT/Gemfile.lock $RAILS_ROOT/../
COPY --chown=rails_user --from=build-env $RAILS_ROOT/yarn.lock $RAILS_ROOT/../
COPY --chown=rails_user --from=build-env $RAILS_ROOT/node_modules/ $RAILS_ROOT/../node_modules/

RUN echo $COMMIT_HASH > public/commit.txt

ENTRYPOINT ["./entrypoint.sh"]
CMD ["start-server"]
