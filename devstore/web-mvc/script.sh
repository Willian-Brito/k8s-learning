#!/bin/bash

# Adicionar entrada no arquivo hosts para o domínio devstore.info
sudo nano /etc/hosts
192.168.58.2 devstore.info

# Configurar o túnel do Minikube para expor aplicação web 
minikube tunnel -p multinode

# Instalar o web-mvc via Helm Chart
helm install --debug web-mvc -f ./web-mvc/values.yaml ./api-template -n devstore

# Testar a conectividade de rede
kubectl run test-network --image=nicolaka/netshoot -i --tty --rm

# Testar o endpoint de saúde do web-mvc
curl -k https://web-mvc.devstore/healthz
