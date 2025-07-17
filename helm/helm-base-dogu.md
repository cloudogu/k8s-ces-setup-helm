# Dogus via Helm Chart installieren

## Credentials im Cluster anlegen

```bash
./helm/scripts/setup_credentials_for_base_dogu.sh \
    admin \
    admin1234 \
    admin@example.com
```

## Helm Chart installieren

```bash
helm install base-dogu01 ./helm/helm-base-dogu-v01/
```