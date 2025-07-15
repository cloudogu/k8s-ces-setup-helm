# Variant 01: Zuerst Component-Operator, danach Komponenten via CR


## Component-Operators und Component-Operator-CRD installieren

### Namespace im Cluster anlegen

```bash
kubectl create namespace ecosystem
```


### Component-Operator konfigurieren

```bash
HELM_REPO_ENDPOINT=oci://registry.cloudogu.com
 HELM_REPO_USERNAME=<user>
 HELM_REPO_PASSWORD=<password> # Leerzeichen am Anfang verhindert den Eintrag in die History
```

```bash
kubectl -n ecosystem create configmap component-operator-helm-repository --from-literal=endpoint="${HELM_REPO_ENDPOINT}" --from-literal=schema=oci
kubectl -n ecosystem create secret generic component-operator-helm-registry \
  --from-literal=config.json="$(echo \"{"auths": {"${HELM_REPO_ENDPOINT}": {"auth": "$(printf "%s:%s" "${HELM_REPO_USERNAME}" "${HELM_REPO_PASSWORD}" | base64 -w0)"}}}\")"
```


### Operator und CRD installieren


```bash
$ helm registry login -u <user> registry.cloudogu.com
Password: ************************
Login succeeded
```

Der Name der Helm-Installion muss dem Namen der Komponente entsprechen. Diese zwei Komponenten werden 
nochmal als CR im nächsten Schritt installiert. Das ist notwendig, damit sie als Komponenten 
im Cluster aufgelistet werden. Das geschieht mit Hilfe des Component-Operators und der erwartet,
dass die Namen übereinstimmen.

```bash
helm install -n ecosystem k8s-component-operator-crd oci://registry.cloudogu.com/k8s/k8s-component-operator-crd --version 1.10.0
helm install -n ecosystem k8s-component-operator oci://registry.cloudogu.com/k8s/k8s-component-operator --version 1.10.0
```


## Installation der Komponenten

### Values des Helm-Charts konfigurieren

```yaml
doguregistry:
  endpoint: https://dogu.cloudogu.com/api/v2/dogus
  url_schema: https://dogu.cloudogu.com/api/v2/dogus_SCHEMA
  username: ""
  password: ""

registry:
  endpoint: https://registry.cloudogu.com
  username: ""
  password: ""
  email: ""

certificate:
  type: "selfsigned"
  crt: ""
  key: ""

config:
  domain:
  fqdn:
  admin_group: cesAdmin
  default_dogu: ""
  k8s:
    internal_ip: ""
    use_internal_ip: "false"
  mail_address: ""
```

### Komponenten mit Helm-Chart installieren

```bash
helm template \
    -f target/values.yaml \
    --set-string doguregistry.username="$(gopass show  -o me/ces/harbor username)" \
    --set-string doguregistry.password="$(gopass show  -o me/ces/harbor)" \
    --set-string registry.username="$(gopass show  -o me/ces/harbor username)" \
    --set-string registry.password="$(gopass show  -o me/ces/harbor)" \
    comp01 ./helm/helm-base-comp-variant-01/ > test04.yaml
```





## TODOs

Der Blueprint-Komponent lässt sich nicht als CR installieren. Dieser Fehler tritt auf:

```text
 Warning  Installation  19s (x2 over 36s)  k8s-component-operator  Installation failed. Reason: failed to install chart for component k8s-blueprint-operator-crd: error while installOrUpgrade chart oci://registry.cloudogu.com/k8s/k8s-blueprint-operator-crd: failed to install release "k8s-blueprint-operator-crd": Unable to continue with install: CustomResourceDefinition "blueprints.k8s.cloudogu.com" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "k8s-blueprint-operator-crd": current value is "k8s-blueprint-lib-crd"
```