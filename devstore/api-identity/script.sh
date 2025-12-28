#!/bin/bash

# Gerar o template do Helm para o api-identity
helm template --debug -f ./api-identity/values.yaml ./api-template > api-identity.yaml

# Gerar o yaml da secret de conexão com o banco de dados PostgreSQL
kubectl create secret generic identity-connection -n devstore --from-literal=CUSTOMCONNSTR_DefaultConnection="Server=postgresql.infra.svc.cluster.local;Port=5432;Database=DBIdentity;User Id=postgres;Password=postgres;" -o yaml --dry-run=client > ./api-identity/identity-connection-secret.yaml

# Habilitar o addon de ingress no minikube (perfil multinode)
minikube addons enable ingress -p multinode

# Aplicar o manifest do identity-connection-secret no cluster Kubernetes
kubectl apply -f identity-connection-secret.yaml -n devstore

# Instalar o api-identity via Helm Chart
helm install --debug api-identity -f api-common.yaml -f ./api-identity/values.yaml ./api-template -n devstore

# Desinstalar o api-identity via Helm Chart
helm uninstall api-identity -n devstore

# Testar a conectividade de rede
kubectl run test-network --image=nicolaka/netshoot -i --tty --rm

# Testar o endpoint de saúde do api-identity
curl -k https://api-identity.devstore/healthz
curl -k https://api-identity.devstore/healthz-infra