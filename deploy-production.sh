#!/bin/bash

set -e

docker build -t gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT .

gcloud auth activate-service-account --key-file ${GOOGLE_APPLICATION_CREDENTIALS}

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials $CLUSTER_NAME

gcloud auth configure-docker
docker push gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}

gcloud container images add-tag gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:latest

kubectl config view
kubectl config current-context

kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_CONTAINER_NAME}=gcr.io/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT