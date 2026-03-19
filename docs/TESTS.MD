# Tests

This chart uses three complementary automated test layers:

- `tests/units/` for fast `helm-unittest` suites and backward-compatibility checks
- `tests/smokes/` for render and schema smoke scenarios
- `tests/e2e/` for kind-based chart installation against real Flux CRDs

The e2e layer is kept local because it depends on Docker, kind, and outbound network access.

## Unit Tests

Unit tests focus on chart-owned behavior rather than repeating full Flux payloads field by field.

Covered checks:

1. `rendering_contract_test.yaml`
   Verifies generic helper behavior:
   - `nameOverride`
   - merged labels and annotations
   - namespace fallback
   - global and per-resource `apiVersion` overrides

2. `example_resources_test.yaml`
   Verifies that `values.yaml.example` renders every supported Flux kind and keeps representative assertions for the example spec payloads.

3. `backward_compatibility_test.sh`
   Renders the current chart with `values.yaml` from previous stable git tags and verifies that old values still pass `helm lint` and `helm template`.

## Smoke Tests

Smoke tests stage a clean temporary copy of the chart containing only:

- `Chart.yaml`
- `values.yaml`
- `values.yaml.example`
- `values.schema.json`
- `templates/`

Covered scenarios:

1. `default-empty`
   Verifies that the chart renders no manifests with default values.

2. `schema-invalid-list-contract`
   Verifies that the schema rejects the old list-based contract and enforces map-based resource collections.

3. `rendering-contract`
   Verifies the helper contract with representative `GitRepository` and `HelmRelease` fixtures.

4. `example-render`
   Renders `values.yaml.example` and verifies that all supported Flux kinds are produced.

5. `example-kubeconform`
   Keeps kubeconform wired for full-flow validation. By default it skips Flux kinds because public schema registries do not consistently ship JSON schemas for the whole Flux API surface.

## E2E Tests

`tests/e2e/test-e2e.sh` performs the following steps:

1. Starts a disposable kind cluster from `tests/e2e/kind.yaml`.
2. Applies Flux CRDs from the upstream `flux2/manifests/crds` kustomization.
3. Runs `helm upgrade --install` against the root chart with `tests/e2e/values/install.values.yaml`.
4. Verifies the installed Flux objects with `kubectl get`.
5. Cleans up the cluster on exit.

The e2e values file exercises every rendered kind with a minimally valid spec intended for CRD admission, not for a full controller-backed reconciliation flow.
