#!/usr/bin/env bash
# Lint and unit-test the chart the way service CI packages it: a copy with
# testdata/migrations/ added as migrations/. The chart on its own (no
# migrations/) is not deployable and fails to render on purpose.
# Needs helm and the helm-unittest plugin.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

cp -r "$here" "$work/database-schema"
cp -r "$here/testdata/migrations" "$work/database-schema/migrations"

helm lint "$work/database-schema" \
  --set database.remoteRef=/bindings/dev/databases/example-db
helm unittest "$work/database-schema"

# Without migrations/ the chart must refuse to render.
if helm template t "$here" --set database.remoteRef=/x >/dev/null 2>&1; then
  echo "expected rendering without migrations/ to fail" >&2
  exit 1
fi
echo "ok: rendering without migrations/ fails"
