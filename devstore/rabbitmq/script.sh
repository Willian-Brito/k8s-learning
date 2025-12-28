#!/bin/bash

# Aplicar os manifests do RabbitMQ no cluster Kubernetes
kubectl apply -f ./rabbitmq -R 

# PostgreSQL via Helm Chart
helm repo add cetic https://cetic.github.io/helm-charts

helm install postgresql cetic/postgresql -n infra