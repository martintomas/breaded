#!/usr/bin/env bash
set -e

case ${RAILS_ENV} in
    *)
        echo "Environment: ${RAILS_ENV}"
esac

synchronize_with_project_directory() {
  if [[ "${RAILS_ENV}" != "production" ]]; then
    echo "Synchronization with docker image"

    cp ../Gemfile.lock .
    cp ../yarn.lock .
    rm -rf node_modules
    ln -s ../node_modules node_modules
  fi
}

copy_assets_to_cdn() {
  if [[ "${RAILS_ENV}" = "production" ]]; then
    echo "Copying assets to CDN"
    rake assets:to_cdn
    echo "Finished copying assets to CDN"
  fi
}

start_server() {
    if [[ "${RAILS_ENV}" = "production" ]]; then
      rails db:migrate && rails server --port 3000 --binding 0.0.0.0 -e ${RAILS_ENV}
    else
      rm -rf tmp/pids/server.pid
      rails db:migrate
      bin/webpack-dev-server --port 3035 --host 0.0.0.0 &
      rails server --port 3000 --binding 0.0.0.0 -e ${RAILS_ENV}
    fi
}

start_background_job() {
    echo "Starting background job in ${RAILS_ENV} mode"
    bundle exec sidekiq -C config/sidekiq.yml
}

synchronize_with_project_directory
copy_assets_to_cdn

if [[ "$1" = "start-server" ]]; then
    start_server

elif [[ "$1" = "start-background-job" ]]; then
    start_background_job

else
    echo "No known command given at entrypoint. Running exec \"$@\""
    exec "$@"
fi
