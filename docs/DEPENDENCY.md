# Development Dependencies

This document describes the local tools needed to develop, document, and test the `nuc-fluxcd` Helm chart.

Primary entry points:

- `make lint`
- `make docs`
- `make test-unit`
- `make test-compat`
- `make test-smoke`
- `make test-e2e`

## Dependency Matrix

| Tool | Why it is needed | Required for |
|------|------------------|--------------|
| `git` | repository operations and reading tagged `values.yaml` in compatibility checks | development, `make test-compat` |
| `helm` | linting, templating, install/upgrade flows, `helm-unittest` plugin host | all workflows |
| `helm-unittest` | chart unit test plugin | `make test-unit` |
| `python3` | smoke-test runner | `make test-smoke`, `make test-smoke-fast` |
| `PyYAML` | smoke-test Python dependency | `make test-smoke`, `make test-smoke-fast` |
| `kubeconform` | optional manifest validation in the full smoke suite | `make test-smoke` |
| `pre-commit` | local git hook manager for auto-regenerating `README.md` on commit | documentation workflow |
| `helm-docs` | README values-table generator | `make docs`, pre-commit hook |
| `docker` | `kind` runtime and fallback runtime for `helm-docs` wrapper | `make test-e2e`, optional `make docs` |
| `kubectl` | cluster verification in e2e tests | `make test-e2e` |
| `kind` | disposable local Kubernetes cluster for e2e | `make test-e2e` |

## Repository Defaults

If you want local behavior close to repository defaults, use:

- `kubeconform`: `v0.6.7`
- `kindest/node`: `v1.35.0`
- `KUBE_VERSION`: `1.35.2`

The chart itself targets Flux CRDs from the upstream [`flux2/manifests/crds`](https://github.com/fluxcd/flux2/blob/main/manifests/crds/kustomization.yaml) kustomization.

## Notes

- `make test-e2e` requires outbound access because it boots a kind node image and applies Flux CRDs from GitHub.
- Public JSON schema catalogs do not cover the full Flux API surface consistently. The default smoke configuration therefore skips Flux kinds in `kubeconform` unless you supply a suitable schema source.
- `KUBECONFORM_SKIP_KINDS` augments the repository-default Flux skip list in the smoke runner, which keeps CI-specific skip additions from re-enabling unsupported Flux kinds by accident.
- The repository is shell-first for compatibility and e2e flows. On Windows, prefer WSL2.
