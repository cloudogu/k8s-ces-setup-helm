# Variant 01: Zuerst Component-Operator, danach Komponenten via CR


## Installation

1. Namespace anlegen

```bash
kubectl create namespace ecosystem
```

2. Mit Helm in die Registry einloggen

```bash
$ helm registry login -u <user> registry.cloudogu.com
Password: ************************
Login succeeded
```

3. Wenn nötig, ein selbst signiertes Zertifikate erstellen

```bash
./helm/scripts/self_signed_cert.sh k3s.local 192.168.56.2 target/cert.crt target/cert.key
```

4. Setup ausführen

```bash
./helm/scripts/setup_base_comp_variant-01.sh \
   https://registry.cloudogu.com \
   "$(gopass show  -o me/ces/harbor username)" \
   "$(gopass show  -o me/ces/harbor)" \
   mail.example.com \
   target/cert.crt \
   target/cert.key \
   selfsigned \
   https://dogu.cloudogu.com/api/v2/dogus \
   https://dogu.cloudogu.com/api/v2/dogus_SCHEMA \
   "$(gopass show  -o me/ces/harbor username)" \
   "$(gopass show  -o me/ces/harbor)" \
   k3s.local \
   192.168.56.2 \
   cesAdmin \
   mail@example.com \
   "" \
   false \
   "" \
   registry.cloudogu.com \
   1.10.0 \
   1.10.0
```

5. Helm-Chart installieren

```bash
helm install -n ecosystem base-comp-01 ./helm/helm-base-comp-variant-01/
```


## TODOs

Der Blueprint-Komponent lässt sich nicht als CR installieren. Dieser Fehler tritt auf:
```text
 Warning  Installation  19s (x2 over 36s)  k8s-component-operator  Installation failed. Reason: failed to install chart for component k8s-blueprint-operator-crd: error while installOrUpgrade chart oci://registry.cloudogu.com/k8s/k8s-blueprint-operator-crd: failed to install release "k8s-blueprint-operator-crd": Unable to continue with install: CustomResourceDefinition "blueprints.k8s.cloudogu.com" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "k8s-blueprint-operator-crd": current value is "k8s-blueprint-lib-crd"
```

---
In `k8s-ces-setup` wird das Secret `ecosystem-certificate` als Typ `Opaque` angelegt. Mit `kubectl` kann man
ein Secret vom Typ `kubernetes.io/tls` anlegen. Es sieht so aus, als ob das Ecosystem-Certificate so ein Secret 
sein sollte.

Das Ecosystem-Certificate hat keine Label durch `k8s-ces-setup` mitbekommen. Anlegen?