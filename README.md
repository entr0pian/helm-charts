# helmcharts

Helm charts for the taskapp Kubernetes stack. Each chart is deployed independently via ArgoCD. GitOps configuration lives in the companion repo [`argocd`](https://github.com/entr0pian/argocd).

## Repository Structure

```
helm-charts/
├── backend/        # Backend API deployment, service, smoke-test job
├── frontend/       # Frontend deployment, service, ingress, HPA
├── database/       # PostgreSQL StatefulSet and seeder job
├── platform/       # Cluster-wide resources: LimitRange, PrometheusRules, Grafana dashboard, ExternalSecrets, ClusterSecretStore
├── common/         # Shared library chart (label helpers)
└── backend-operator/ # Kubebuilder operator: CRD, RBAC, manager deployment
```

## Charts

### `backend`
Deploys the Go REST API. Manages a `Deployment`, `Service`, and `ConfigMap`. Supports optional KEDA autoscaling via `ScaledObject` and `TriggerAuthentication` for SQS-based scaling. A PostSync smoke-test `Job` runs after every ArgoCD sync and fires a Slack notification on failure.

Image tag is updated automatically by CI on every push to `main` in the backend repo.

### `frontend`
Deploys the React + Vite SPA served by nginx. Manages a `Deployment`, `Service`, `Ingress`, `HPA`, and `ServiceMonitor` for Prometheus scraping.

### `database`
Deploys PostgreSQL as a `StatefulSet` with a `PersistentVolumeClaim`. A seed `Job` initialises the schema on first deployment.

### `platform`
Cluster-wide resources applied once per environment:
- `LimitRange` — enforces default requests/limits and a 4× max ratio on all containers in the `default` namespace
- `ClusterSecretStore` — configures External Secrets Operator to authenticate against AWS Secrets Manager using IAM credentials bootstrapped by Terraform
- `ExternalSecret` (database) — syncs `taskapp/{env}/database` from AWS SM into a native `Secret`
- `ExternalSecret` (backend credentials, optional) — syncs `taskapp/{env}/backend-credentials` for SQS access
- `PrometheusRules` — OOMKilled, HighCPUUtilization (>80% for 5m), HighMemoryUtilization (>80% for 5m) alerts scoped to the `default` namespace
- `Grafana dashboard` — CPU and memory usage vs limits for all `taskapp-*` pods; provisioned via ConfigMap with label `grafana_dashboard: "1"`

### `common`
Shared library chart. Provides two Helm template helpers used by all other charts:
- `taskapp.labels` — standard label set
- `taskapp.selectorLabels` — selector label set

### `backend-operator`
Helm packaging for the taskapp backend operator. Installs the `Backend` CRD, RBAC, ServiceAccount, and the operator manager `Deployment`. The operator source lives in [`backend-operator`](https://github.com/entr0pian/backend-operator).

## Secrets Architecture

AWS Secrets Manager secrets are synced into the cluster by External Secrets Operator. The `ClusterSecretStore` (in `platform`) authenticates using an `aws-credentials` Secret in the `external-secrets` namespace, which is provisioned by Terraform during cluster bootstrap — not managed by these charts.

| AWS SM Path | K8s Secret | Consumer |
|---|---|---|
| `taskapp/{env}/database` | `taskapp-database-secret` | Database and backend pods |
| `taskapp/{env}/backend-credentials` | `taskapp-backend-aws-credentials` | Backend pod (SQS), KEDA TriggerAuthentication |
