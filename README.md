# README

This repository contains Breaded app. On next pages, basic information of how to run this app is provided.

## Technologies
**Mandaroty**
 - Ruby - Rails 6 framework
 
**Additional Libraries**
 - Active Admin - app contains admimnistration available for administrators and accessible via /admin url. Administration allows to modify all basic data -- foods, produces, categories, etc.
 - Cancancan - authorization of users
 - Devise - autentization of users
 - Sidekiq - background job worker
 - Stripe - payment gate
 - Twilio - sms gate
 - webpacker - FE is build via WebPacker
 - Turbolinks
 - Stimulus - main js library user to organize all dynamic behaviour to controllers
 - html-slim - all html is written at SLIM
 
**Docker Support**

Repository contains Dockerfile (dev and production version) and can be run at dockerized environment or at local machine with help of docker-compose command.

## External Services
Several external services is used to provide app with all required features.

- DigitalOcean -- server, app is prepared to be run at cluster environment with installed Kubernetes -- please see deploy folder for details (`deploy.sh` script can be used to push current master to prepared server)
- Stripe -- payment gate
- Twilio -- sms gate
- Sentry -- exception monitoring
- Email

# How to run
To run application at your local environment, you have basically two options:
1) install docker-compose tool and run all required services via docker composer. Please use commands `docker-compose build` and `docker-compose up`
2) install all your services on your local machine --> It is absolutely necessary to install PostgreSQL, Redis and Ruby (+ rvm) at your machine.

Before you run app, please run these commands:
1) `copy .env.demo .env` -- prepare all required env variables. Please modify these env variables based on option which you have chosen at previous step. If you have decided to install all your services locally (and not use docker compose), modify appropriate urls, passwords, etc. for your PostgreSQL and Redis instance
2) `docker-compose run web rake db:rebuild` or `rake db:rebuild` -- prepares database
3) `docker-compose run web rake db:demo_seed` or `rake db:demo_seed` -- uploads minimal basic demo data to database
