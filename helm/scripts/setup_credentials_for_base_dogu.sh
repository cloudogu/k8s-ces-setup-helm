#!/bin/bash

ADMIN_USERNAME=$1
ADMIN_PASSWORD=$2
ADMIN_MAIL=$3

LDAP_CONFIG_YAML=$(cat <<EOF
admin_username: ${ADMIN_USERNAME}
admin_mail: ${ADMIN_MAIL}
admin_member: "true"
EOF
)

kubectl -n ecosystem create configmap ldap-config --from-literal=config.yaml="${LDAP_CONFIG_YAML}"
kubectl -n ecosystem label configmap ldap-config app=ces dogu.name=ldap k8s.cloudogu.com/type=dogu-config


LDAP_SECRET_CONFIG_YAML=$(cat <<EOF
admin_password: ${ADMIN_PASSWORD}
EOF
)

kubectl -n ecosystem create secret generic ldap-config --from-literal=config.yaml="${LDAP_SECRET_CONFIG_YAML}"
kubectl -n ecosystem label secret ldap-config app=ces dogu.name=ldap k8s.cloudogu.com/type=sensitive-config