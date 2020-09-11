FROM ruby:2.6.3
LABEL maintainer="Martin Tomas <martintomas.it@gmail.com>"

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# add node
ENV NODE_VERSION=12.6.0
RUN apt update
RUN apt install -y curl postgresql-client
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version
RUN npm install --global yarn

ARG INSTALL_CHROMIUM
RUN sh -c 'if [ "$INSTALL_CHROMIUM" = true ]; then apt install -y chromium; else echo "Skipping chrome installation"; fi'

COPY Gemfile ./
RUN bundle install

COPY package.json ./
RUN yarn install --check-files

COPY . .

ARG COMMIT_HASH
RUN echo $COMMIT_HASH > public/commit.txt

ENTRYPOINT ["./entrypoint.sh"]
CMD ["start-server"]
