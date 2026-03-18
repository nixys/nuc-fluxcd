# Agent Guide

This repository is the FluxCD-oriented counterpart of the baseline single-chart Helm repository used as a reference in `nuc-native-gateway`.

Repository expectations:

- one chart at the repository root
- one generic values contract
- one example values file that exercises every supported Flux kind
- one helper layer for shared rendering behavior
- layered tests under `tests/units`, `tests/smokes`, and `tests/e2e`

## Flux Rules

Keep these assumptions explicit when changing the repository:

- the chart renders Flux custom resources only
- controller installation and CRD installation are separate concerns
- support depends on the CRDs available in the target cluster
- per-kind `apiVersion` overrides are part of the public contract

When changing defaults or tests, keep them aligned with the upstream Flux CRD set referenced by `flux2/manifests/crds`.
