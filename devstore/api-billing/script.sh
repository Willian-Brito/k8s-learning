#!/bin/bash

# Gerar yaml da secret de conexão com o banco de dados PostgreSQL
kubectl create secret generic billing-connection -n devstore --from-literal=CUSTOMCONNSTR_DefaultConnection="Server=postgresql.infra.svc.cluster.local;Port=5432;Database=DBBilling;User Id=postgres;Password=postgres;" -o yaml --dry-run=client > ./api-billing/billing-connection-secret.yaml

# Aplicar o secret da api-billing
kubectl apply -f ./api-billing/billing-connection-secret.yaml -n devstore

# Instalar o api-billing via Helm Chart
helm install --debug api-billing -f api-common.yaml -f ./api-billing/values.yaml ./api-template -n devstore

# Testar a conectividade de rede
kubectl run test-network --image=nicolaka/netshoot -i --tty --rm

# Testar o endpoint de saúde do api-billing
curl -k https://api-billing.devstore/healthz
curl -k https://api-billing.devstore/healthz-infra
