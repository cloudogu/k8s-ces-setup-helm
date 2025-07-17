#!/bin/bash

DOCKER_SERVER=$1
DOCKER_USERNAME=$2
DOCKER_PASSWORD=$3
DOCKER_EMAIL=$4
CERTIFICATE_CERT_PATH=$5
CERTIFICATE_KEY_PATH=$6
CERTIFICATE_TYPE=$7   # external | selfsigned
DOGU_REGISTRY_ENDPOINT=$8
DOGU_REGISTRY_SCHEMA=$9
DOGU_REGISTRY_USERNAME=${10}
DOGU_REGISTRY_PASSWORD=${11}
CES_DOMAIN=${12}
CES_FQDN=${13}
CES_ADMIN_GROUP=${14}
CES_MAIL_ADDRESS=${15}
CES_INTERNAL_IP=${16}
CES_USE_INTERNAL_IP=${17}
CES_DEFAULT_DOGU=${18}

echo "create docker registry secret"
kubectl -n ecosystem create secret docker-registry ces-container-registries \
   --docker-server=${DOCKER_SERVER} \
   --docker-username=${DOCKER_USERNAME} \
   --docker-password=${DOCKER_PASSWORD} \
   --docker-email=${DOCKER_EMAIL}
kubectl -n ecosystem label secret ces-container-registries app=ces

echo "create ecosystem certificate secret"
kubectl -n ecosystem create secret tls ecosystem-certificate --cert=${CERTIFICATE_CERT_PATH} --key=${CERTIFICATE_KEY_PATH}
kubectl -n ecosystem label secret ecosystem-certificate app=ces

echo "create dogu operator registry secret"
kubectl -n ecosystem create secret generic k8s-dogu-operator-dogu-registry \
  --from-literal=endpoint="${DOGU_REGISTRY_ENDPOINT}" \
  --from-literal=urlschema="${DOGU_REGISTRY_SCHEMA}" \
  --from-literal=username="${DOGU_REGISTRY_USERNAME}" \
  --from-literal=password="${DOGU_REGISTRY_PASSWORD}"
kubectl -n ecosystem label secret k8s-dogu-operator-dogu-registry app=ces

echo "create global config"
CONFIG_YAML=$(cat <<EOF
domain: "${CES_DOMAIN}"
fqdn: "${CES_FQDN}"
admin_group: "${CES_ADMIN_GROUP}"
mail_address: "${CES_MAIL_ADDRESS}"
default_dogu: "${CES_DEFAULT_DOGU}"
k8s:
  internal_ip: "${CES_INTERNAL_IP}"
  use_internal_ip: "${CES_USE_INTERNAL_IP}"
certificate:
  type: "${CERTIFICATE_TYPE}"
  server.crt: |
$(cat ${CERTIFICATE_CERT_PATH} | sed 's/^/    /')
  server.key: |
$(cat ${CERTIFICATE_KEY_PATH} | sed 's/^/    /')
EOF
)

kubectl -n ecosystem create configmap global-config --from-literal=config.yaml="${CONFIG_YAML}"
kubectl -n ecosystem label configmap global-config app=ces k8s.cloudogu.com/type=global-config
