# Variant 02: Ohne Component-Operator

## Installation

### Abhänigkeiten des Helm-Charts updaten

```bash
helm dependency update ./helm/helm-base-comp-variant-02
```

### Helm Chart mit CRDs anpasen

Da CRDs im Chart der Abhängigkeiten noch nicht unter `crds` abgelegt sind, muss man das vorerst manuell machen. 
Dafür unter `charts` ein Verzeichnis anlegen und die CRDs aus dem Original-Chart ins Verzeichnis `crds` kopieren. 
Alle anderen Dateien aus dem Original-Chart übernehmen. Die Abhängigkeiten müssen danach aus dem Chart entfernt 
werden. Danach nochmal `helm dependency update ./helm-base-comp-variant-02` ausführen. 

Das Ergebnis muss so aussehen:

```text
helm-base-comp-variant-02
├── Chart.lock
├── charts
│   ├── k8s-backup-operator-1.4.6.tgz
│   ├── k8s-backup-operator-crd-1_4_6
│   │   ├── Chart.yaml
│   │   └── crds
│   │       ├── k8s.cloudogu.com_backupschedules.yaml
│   │       ├── k8s.cloudogu.com_backups.yaml
│   │       └── k8s.cloudogu.com_restores.yaml
│   ├── k8s-blueprint-operator-2.6.0.tgz
│   ├── k8s-blueprint-operator-crd_1_3_0
│   │   ├── Chart.yaml
│   │   └── crds
│   │       └── k8s.cloudogu.com_blueprints.yaml
│   ├── k8s-dogu-operator-3.11.2.tgz
│   ├── k8s-dogu-operator-crd-2_9_0
│   │   ├── Chart.yaml
│   │   └── crds
│   │       ├── k8s.cloudogu.com_dogurestarts.yaml
│   │       └── k8s.cloudogu.com_dogus.yaml
│   ├── k8s-service-discovery-2.0.0.tgz
│   ├── k8s-snapshot-controller-8.2.1-2.tgz
│   ├── k8s-snapshot-controller-crd-8_2_1
│   │   ├── Chart.yaml
│   │   └── crds
│   │       ├── groupsnapshot.storage.k8s.io_volumegroupsnapshotclasses.yaml
│   │       ├── groupsnapshot.storage.k8s.io_volumegroupsnapshotcontents.yaml
│   │       ├── groupsnapshot.storage.k8s.io_volumegroupsnapshots.yaml
│   │       ├── snapshot.storage.k8s.io_volumesnapshotclasses.yaml
│   │       ├── snapshot.storage.k8s.io_volumesnapshotcontents.yaml
│   │       └── snapshot.storage.k8s.io_volumesnapshots.yaml
│   └── k8s-velero-10.0.1-2.tgz
└── Chart.yaml
```

## Namespace anlegen
    
```bash
kubectl create namespace ecosystem
```

## Credentials anlegen

```bash
./helm/scripts/self_signed_cert.sh k3s.local 192.168.56.2 target/cert.crt target/cert.key
```

## Helm Chart installieren

```bash
helm -n ecosystem install base-comp-variant02 ./helm/helm-base-comp-variant-02
```

## TODO

- [ ] Für alle Charts, die CRDs enthalten, CRDs ins Verzeichnis `crds` legen. Diese Vorlagen können nicht
      getemplatet werden.
- [ ] Ein Job vom Backup-Operator wird im Default-Namespace angelegt.
- [ ] Beim deinstallieren der Helm-Charts bleibt das Secret `velero-repo-credentials` stehen, obwohl es durch 
      das Helm-Chart installier wurde.
- [ ] Longhorn ist noch nicht dabei.
- [ ] CertManager ist noch nicht dabei. Ist der notwendig?
- [ ] Loki, Prometheus ist noch nicht dabei.