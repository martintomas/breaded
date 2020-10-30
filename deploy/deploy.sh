#!/usr/bin/env bash
set -e

cd $(dirname "${BASH_SOURCE[0]}")

if [[ -n $(git status -s) ]]; then
  echo "Merge unfinished work before you deploy current version of master to production!"
  exit
fi

ssh-add ~/.ssh/personal
git checkout master
git pull

COMMIT_HASH=$(git log -n 1 --pretty=format:"%h")

docker build -f ../Dockerfile.production ../ -t breaded-production:$COMMIT_HASH --build-arg COMMIT_HASH=$COMMIT_HASH
docker tag breaded-production:$COMMIT_HASH registry.digitalocean.com/breaded/breaded-production:$COMMIT_HASH
docker push registry.digitalocean.com/breaded/breaded-production:$COMMIT_HASH

kubectl config use-context do-lon1-breaded-cluster
kubectl apply -f web-env-configmap.yaml
kubectl apply -f breaded-secrets.yaml
kubectl set image deployment/web web=registry.digitalocean.com/breaded/breaded-production:$COMMIT_HASH
kubectl set image deployment/background-job background-job=registry.digitalocean.com/breaded/breaded-production:$COMMIT_HASH

#docker image rmi breaded-production:$COMMIT_HASH
