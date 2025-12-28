#!/bin/bash

# Adicionar entrada no arquivo hosts para o domínio status.devstore.info
sudo nano /etc/hosts
192.168.58.2 status.devstore.info

# Configurar o túnel do Minikube para expor aplicação web 
minikube tunnel -p multinode

# Gerar yaml da secret de conexão com o banco de dados PostgreSQL
kubectl create secret generic status-connection -n devstore --from-literal=CUSTOMCONNSTR_DefaultConnection="Server=sqlserver.infra;Database=DBStatus;MultipleActiveResultSets=true;User Id=sa;Password=Teste@123" -o yaml --dry-run=client > ./web-status/status-connection-secret.yaml

# Aplicar o secret da web-status
kubectl apply -f ./web-status/status-connection-secret.yaml -n devstore

# Instalar o web-status via Helm Chart
helm install --debug web-status -f api-common.yaml -f ./web-status/values.yaml ./api-template -n devstore

# Testar a conectividade de rede
kubectl run test-network --image=nicolaka/netshoot -i --tty --rm

# Testar o endpoint de saúde do web-status
curl -k https://web-status.devstore/healthz
curl -k https://web-status.devstore/healthz-infra
