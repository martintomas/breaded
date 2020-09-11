#!/usr/bin/env bash
set -e

case ${RAILS_ENV} in
    *)
        echo "Environment: ${RAILS_ENV}"
esac

start_server() {
    if [[ "${RAILS_ENV}" = "development" ]]; then
        echo "Starting server in ${RAILS_ENV} mode. Skipping webpacker:compile"
        rm -rf tmp/pids/server.pid
        bundle exec rails db:migrate && bundle exec rails server --port 3000 --binding 0.0.0.0 -e ${RAILS_ENV}
    else
        echo "Starting server ${RAILS_ENV} mode. Running db:migrate and webpacker:compile"
        rails db:migrate && rails webpacker:compile && bundle exec rails server --port 3000 --binding 0.0.0.0 -e ${RAILS_ENV}
    fi
}

start_background_job() {
    echo "Starting background job in ${RAILS_ENV} mode"
    bundle exec sidekiq -C config/sidekiq.yml
}

if [[ "$1" = "start-server" ]]; then
    start_server

elif [[ "$1" = "start-background-job" ]]; then
    start_background_job

else
    echo "No known command given at entrypoint. Running exec \"$@\""
    exec "$@"
fi
