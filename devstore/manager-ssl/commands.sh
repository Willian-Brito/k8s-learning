#!/bin/sh

# Verificar se existe namespace devstore
kubectl get ns

# Caso não exista criar
kubectl create ns devstore

# Criar service account
kubectl apply -f serviceaccount.yaml

# Conectar no service account
kubectl attach ssl-manager -i -t -n devstore

# Criar variaveis de ambeinte
APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

# Listar secrets do namespace devstore
curl --cacert $CACERT -H "Authorization: Bearer $TOKEN" -X GET $APISERVER/api/v1/namespaces/devstore/secrets/devstore-ssl

# Pegar o secret devstore-ssl
SECRET=$(curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" -X GET $APISERVER/api/v1/namespaces/devstore/secrets/devstore-ssl)

echo $SECRET | jq -r '.code // 200' # 404

# Criar senha aleatoria para o certificado
CERT_PASSWORD=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()_+' | head -c 32; echo '')

# Criar senha em base64
CERT_B64_PASSWORD=$(echo -n "$CERT_PASSWORD" | base64)

# Gerar chave RSA
openssl genrsa -out devstore.rs 2048

# Gerar CSR
openssl req -sha256 -new -key devstore.rs -out devstore.csr -subj '/CN=localhost'

# Gerar certificado autoassinado
openssl x509 -req -sha256 -days 365 -in devstore.csr -signkey devstore.rs -out devstore.crt

# Gerar arquivo PFX
openssl pkcs12 -export -out devstore.academy-localhost.pfx -inkey devstore.rs -in devstore.crt -password pass:$CERT_PASSWORD

# Converter PFX para base64
PFX_B64=$(cat devstore.academy-localhost.pfx | base64 | tr -d '\n')

# Criar payload do secret
SECRET_PAYLOAD=$(printf '{"apiVersion":"v1","kind":"Secret","metadata":{"name":"devstore-ssl"},"type":"Opaque","data":{"devstore.academy-localhost.pfx":"%s","password":"%s"}}' $PFX_B64 $CERT_B64_PASSWORD)

# Criar secret no Kubernetes
curl --cacert $CACERT -H  "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -X POST -d "$SECRET_PAYLOAD" $APISERVER/api/v1/namespaces/devstore/secrets

# Deletando secret
curl --cacert $CACERT -H "Authorization: Bearer $TOKEN" -X DELETE $APISERVER/api/v1/namespaces/devstore/secrets/devstore-ssl