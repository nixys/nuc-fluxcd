# NUC FluxCD

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/nuc-fluxcd)](https://artifacthub.io/packages/search?repo=nuc-fluxcd)

Helm chart for rendering FluxCD custom resources from declarative values.

The chart does not install Flux controllers or CRDs. It only renders Flux resources that are already supported by the target cluster. The default API versions are aligned with the CRDs referenced by [`flux2/manifests/crds`](https://github.com/fluxcd/flux2/blob/main/manifests/crds/kustomization.yaml).

## Quick Start

Add the Nixys chart repository:

```bash
helm repo add nixys https://registry.nixys.io/chartrepo/public
# or
helm repo add nixys https://registry.nixys.ru/chartrepo/public
```

Install the chart:

```bash
helm install nuc-fluxcd . \
  --namespace flux-system \
  --create-namespace \
  -f values.yaml.example
```

## Supported Resources

The chart renders one template per Flux kind:

- `Alert`
- `ArtifactGenerator`
- `Bucket`
- `ExternalArtifact`
- `GitRepository`
- `HelmChart`
- `HelmRelease`
- `HelmRepository`
- `ImagePolicy`
- `ImageRepository`
- `ImageUpdateAutomation`
- `Kustomization`
- `OCIRepository`
- `Provider`
- `Receiver`

## Values Model

Each top-level map in [values.yaml](values.yaml) maps resource names to one Flux kind:

- `alerts`
- `artifactGenerators`
- `buckets`
- `externalArtifacts`
- `gitRepositories`
- `helmCharts`
- `helmReleases`
- `helmRepositories`
- `imagePolicies`
- `imageRepositories`
- `imageUpdateAutomations`
- `kustomizations`
- `ociRepositories`
- `providers`
- `receivers`

Every entry uses the same contract:

| Field | Required | Description |
|-------|----------|-------------|
| map key | yes | Resource name used for `metadata.name`. |
| `namespace` | no | Namespace for the resource. Defaults to the Helm release namespace. |
| `labels` | no | Labels merged on top of built-in chart labels and `commonLabels`. |
| `annotations` | no | Annotations merged on top of `commonAnnotations`. |
| `apiVersion` | no | Per-resource API version override. |
| `spec` | no | Raw resource spec rendered as-is. |
| `status` | no | Optional raw status block. Useful for fixtures, not typical production Helm usage. |

Setting a map entry to `null` in a higher-precedence values file suppresses the default resource from a lower-precedence values file.

Global controls:

- `enabled`
- `global`
- `nameOverride`
- `commonLabels`
- `commonAnnotations`
- `apiVersions.*`

The value contract is validated by [values.schema.json](values.schema.json).

## Helm Values

This section is generated from [values.yaml](values.yaml) by `helm-docs`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alerts | object | {} | Alert resources keyed by resource name. |
| alerts.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| alerts.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| alerts.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| alerts.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| alerts.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| alerts.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| apiVersions.alert | string | `"notification.toolkit.fluxcd.io/v1beta3"` | Default apiVersion for Alert resources. |
| apiVersions.artifactGenerator | string | `"source.extensions.fluxcd.io/v1beta1"` | Default apiVersion for ArtifactGenerator resources. |
| apiVersions.bucket | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for Bucket resources. |
| apiVersions.externalArtifact | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for ExternalArtifact resources. |
| apiVersions.gitRepository | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for GitRepository resources. |
| apiVersions.helmChart | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for HelmChart resources. |
| apiVersions.helmRelease | string | `"helm.toolkit.fluxcd.io/v2"` | Default apiVersion for HelmRelease resources. |
| apiVersions.helmRepository | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for HelmRepository resources. |
| apiVersions.imagePolicy | string | `"image.toolkit.fluxcd.io/v1"` | Default apiVersion for ImagePolicy resources. |
| apiVersions.imageRepository | string | `"image.toolkit.fluxcd.io/v1"` | Default apiVersion for ImageRepository resources. |
| apiVersions.imageUpdateAutomation | string | `"image.toolkit.fluxcd.io/v1"` | Default apiVersion for ImageUpdateAutomation resources. |
| apiVersions.kustomization | string | `"kustomize.toolkit.fluxcd.io/v1"` | Default apiVersion for Kustomization resources. |
| apiVersions.ociRepository | string | `"source.toolkit.fluxcd.io/v1"` | Default apiVersion for OCIRepository resources. |
| apiVersions.provider | string | `"notification.toolkit.fluxcd.io/v1beta3"` | Default apiVersion for Provider resources. |
| apiVersions.receiver | string | `"notification.toolkit.fluxcd.io/v1"` | Default apiVersion for Receiver resources. |
| artifactGenerators | object | {} | ArtifactGenerator resources keyed by resource name. |
| artifactGenerators.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| artifactGenerators.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| artifactGenerators.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| artifactGenerators.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| artifactGenerators.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| artifactGenerators.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| buckets | object | {} | Bucket resources keyed by resource name. |
| buckets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| buckets.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| buckets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| buckets.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| buckets.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| buckets.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| commonAnnotations | object | `{}` | Extra annotations applied to every rendered resource. |
| commonLabels | object | `{}` | Extra labels applied to every rendered resource. |
| enabled | bool | `true` | Enable nuc-fluxcd chart rendering. |
| externalArtifacts | object | {} | ExternalArtifact resources keyed by resource name. |
| externalArtifacts.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| externalArtifacts.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| externalArtifacts.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| externalArtifacts.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| externalArtifacts.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| externalArtifacts.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| gitRepositories | object | {} | GitRepository resources keyed by resource name. |
| gitRepositories.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| gitRepositories.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| gitRepositories.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| gitRepositories.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| gitRepositories.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| gitRepositories.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| global | object | `{}` | Compatibility values inherited from umbrella charts. Accepted but ignored by this chart. |
| helmCharts | object | {} | HelmChart resources keyed by resource name. |
| helmCharts.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| helmCharts.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| helmCharts.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| helmCharts.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| helmCharts.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| helmCharts.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| helmReleases | object | {} | HelmRelease resources keyed by resource name. |
| helmReleases.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| helmReleases.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| helmReleases.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| helmReleases.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| helmReleases.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| helmReleases.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| helmRepositories | object | {} | HelmRepository resources keyed by resource name. |
| helmRepositories.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| helmRepositories.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| helmRepositories.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| helmRepositories.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| helmRepositories.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| helmRepositories.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| imagePolicies | object | {} | ImagePolicy resources keyed by resource name. |
| imagePolicies.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| imagePolicies.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| imagePolicies.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| imagePolicies.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| imagePolicies.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| imagePolicies.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| imageRepositories | object | {} | ImageRepository resources keyed by resource name. |
| imageRepositories.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| imageRepositories.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| imageRepositories.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| imageRepositories.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| imageRepositories.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| imageRepositories.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| imageUpdateAutomations | object | {} | ImageUpdateAutomation resources keyed by resource name. |
| imageUpdateAutomations.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| imageUpdateAutomations.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| imageUpdateAutomations.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| imageUpdateAutomations.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| imageUpdateAutomations.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| imageUpdateAutomations.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| kustomizations | object | {} | Kustomization resources keyed by resource name. |
| kustomizations.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| kustomizations.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| kustomizations.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| kustomizations.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| kustomizations.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| kustomizations.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| nameOverride | string | `""` | Override the default chart label name if needed. |
| ociRepositories | object | {} | OCIRepository resources keyed by resource name. |
| ociRepositories.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| ociRepositories.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| ociRepositories.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| ociRepositories.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| ociRepositories.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| ociRepositories.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| providers | object | {} | Provider resources keyed by resource name. |
| providers.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| providers.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| providers.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| providers.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| providers.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| providers.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| receivers | object | {} | Receiver resources keyed by resource name. |
| receivers.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| receivers.__helm_docs_example__.apiVersion | string | chart default for this kind | Per-resource apiVersion override. |
| receivers.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| receivers.__helm_docs_example__.namespace | string | release namespace | Namespace for namespaced resources. Defaults to the Helm release namespace. |
| receivers.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is. |
| receivers.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |

## Included Values Files

- [values.yaml](values.yaml): minimal defaults that render no resources.
- [values.yaml.example](values.yaml.example): complete example covering every supported Flux kind.

## Testing

The repository keeps the same three-layer test structure as the reference chart:

- `tests/units/` for `helm-unittest` suites and backward-compatibility checks
- `tests/smokes/` for render and schema smoke scenarios
- `tests/e2e/` for kind-based Helm install checks against real Flux CRDs

Representative local commands:

```bash
make lint
make test-unit
make test-compat
make test-smoke
make test-e2e
```

Detailed test documentation lives in [docs/TESTS.MD](docs/TESTS.MD). Local dependency setup is documented in [docs/DEPENDENCY.md](docs/DEPENDENCY.md).
