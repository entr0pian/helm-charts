# taskapp-common

A Helm library chart providing shared template utilities for all TaskApp charts.
Library charts contain only named templates (`_*.tpl`) and are never deployed on their own.

## Consumers

| Chart | Dependency entry |
|---|---|
| taskapp-backend | `file://../common` |
| taskapp-frontend | `file://../common` |
| taskapp-database | `file://../common` |

## Available templates

| Template | Usage | Description |
|---|---|---|
| `taskapp.labels` | `{{- include "taskapp.labels" . \| nindent 4 }}` | Full set of standard `app.kubernetes.io/*` labels + `helm.sh/chart` |
| `taskapp.selectorLabels` | `{{- include "taskapp.selectorLabels" . \| nindent 6 }}` | Stable subset safe for `matchLabels` (name + instance only) |

## How to update this chart

### 1. Make your changes

Edit the templates inside `common/templates/`.

### 2. Bump the version

In `common/Chart.yaml`, increment the `version` field following [semver](https://semver.org/):

- **Patch** (`0.1.0` → `0.1.1`): backwards-compatible fix (e.g. label value typo)
- **Minor** (`0.1.0` → `0.2.0`): new template added
- **Major** (`0.1.0` → `1.0.0`): breaking change to an existing template signature

### 3. Update the version in each consumer chart

For every chart that depends on `taskapp-common`, open its `Chart.yaml` and match the version:

```yaml
dependencies:
  - name: taskapp-common
    version: "0.1.1"   # <-- must match common/Chart.yaml
    repository: "file://../common"
```

### 4. Re-run helm dependency update in each consumer

```bash
helm dependency update taskapp-backend/
helm dependency update taskapp-frontend/
helm dependency update taskapp-database/
```

This repackages the library into each chart's `charts/` directory.

### 5. Verify

```bash
helm template test-release taskapp-backend/
```

Check that the rendered output reflects your changes.

---

### Shortcut for local development (skip version bump)

If you are iterating quickly and do not want to bump the version on every change:

```bash
rm taskapp-backend/charts/taskapp-common-*.tgz && helm dependency update taskapp-backend/
```

> **Do not use this shortcut for staging or production releases.** Always bump the version before promoting changes.
