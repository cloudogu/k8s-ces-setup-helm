#!/bin/bash

REGISTRY_ENDPOINT=$1
REGISTRY_USERNAME=$2
REGISTRY_PASSWORD=$3
REGISTRY_EMAIL=$4
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
HELM_REPOSITORY_ENDPOINT=${19}
COMPONENT_OPERATOR_VERSION=${20}
COMPONENT_OPERATOR_CRD_VERSION=${21}

echo "create component operator helm repository"
kubectl -n ecosystem create configmap component-operator-helm-repository \
    --from-literal=endpoint="${HELM_REPOSITORY_ENDPOINT}" \
    --from-literal=schema=oci
kubectl -n ecosystem label configmap component-operator-helm-repository app=ces

CONFIG_JSON=$(cat <<EOF
{
  "auths": {
    "${HELM_REPOSITORY_ENDPOINT}": {
      "auth": "$(printf "%s:%s" ${REGISTRY_USERNAME} ${REGISTRY_PASSWORD} | base64 -w0)"
    }
  }
}
EOF
)

kubectl -n ecosystem create secret generic component-operator-helm-registry --from-literal=config.json="${CONFIG_JSON}"
kubectl -n ecosystem label secret component-operator-helm-registry app=ces

echo "install component operator"
helm install -n ecosystem k8s-component-operator-crd oci://${HELM_REPOSITORY_ENDPOINT}/k8s/k8s-component-operator-crd --version ${COMPONENT_OPERATOR_CRD_VERSION}
sleep 5
kubectl -n ecosystem wait \
    --timeout=30s \
    --for=jsonpath='{.status.conditions[?(@.type=="Established")].status}'=True \
    customresourcedefinition components.k8s.cloudogu.com
helm install -n ecosystem k8s-component-operator oci://${HELM_REPOSITORY_ENDPOINT}/k8s/k8s-component-operator --version ${COMPONENT_OPERATOR_VERSION}

echo "create docker registry secret"
kubectl -n ecosystem create secret docker-registry ces-container-registries \
   --docker-server=${REGISTRY_ENDPOINT} \
   --docker-username=${REGISTRY_USERNAME} \
   --docker-password=${REGISTRY_PASSWORD} \
   --docker-email=${REGISTRY_EMAIL}
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
