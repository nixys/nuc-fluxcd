#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="${ROOT_DIR}/tests/e2e"
CLUSTER_CREATED=false
CLUSTER_NAME="${CLUSTER_NAME:-$(mktemp -u "nuc-fluxcd-e2e-XXXXXXXXXX" | tr "[:upper:]" "[:lower:]")}"
# kindest/node images are published on kind's cadence, not for every Kubernetes patch release.
K8S_VERSION="${K8S_VERSION:-v1.35.0}"
E2E_NAMESPACE="nuc-fluxcd-e2e"
RELEASE_NAME="nuc-fluxcd-e2e"
VALUES_FILE="tests/e2e/values/install.values.yaml"
FLUX_CRD_KUSTOMIZATION_URL="${FLUX_CRD_KUSTOMIZATION_URL:-https://raw.githubusercontent.com/fluxcd/flux2/main/manifests/crds/kustomization.yaml}"

RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

log_error() { echo -e "${RED}Error:${RESET} $1" >&2; }
log_info() { echo -e "$1"; }
log_warn() { echo -e "${YELLOW}Warning:${RESET} $1" >&2; }

show_help() {
  echo "Usage: $(basename "$0") [helm upgrade/install options]"
  echo ""
  echo "Create a kind cluster, install Flux CRDs from flux2/manifests/crds, and run Helm install/upgrade against the root chart."
  echo "Unknown arguments are passed through to 'helm upgrade --install'."
  echo ""
  echo "Environment overrides:"
  echo "  CLUSTER_NAME               Kind cluster name"
  echo "  K8S_VERSION                kindest/node tag"
  echo "  FLUX_CRD_KUSTOMIZATION_URL Raw Flux CRD kustomization.yaml URL"
  echo ""
}

verify_prerequisites() {
  for bin in docker kind kubectl helm; do
    if ! command -v "${bin}" >/dev/null 2>&1; then
      log_error "${bin} is not installed"
      exit 1
    fi
  done
}

cleanup() {
  local exit_code=$?

  if [ "${exit_code}" -ne 0 ] && [ "${CLUSTER_CREATED}" = true ]; then
    dump_cluster_state || true
  fi

  log_info "Cleaning up resources"

  if [ "${CLUSTER_CREATED}" = true ]; then
    log_info "Removing kind cluster ${CLUSTER_NAME}"
    if kind get clusters | grep -q "${CLUSTER_NAME}"; then
      kind delete cluster --name="${CLUSTER_NAME}"
    else
      log_warn "kind cluster ${CLUSTER_NAME} not found"
    fi
  fi

  exit "${exit_code}"
}

dump_cluster_state() {
  log_warn "Dumping Flux resources from ${CLUSTER_NAME}"
  kubectl get \
    alerts.notification.toolkit.fluxcd.io,artifactgenerators.source.extensions.fluxcd.io,buckets.source.toolkit.fluxcd.io,externalartifacts.source.toolkit.fluxcd.io,gitrepositories.source.toolkit.fluxcd.io,helmcharts.source.toolkit.fluxcd.io,helmreleases.helm.toolkit.fluxcd.io,helmrepositories.source.toolkit.fluxcd.io,imagepolicies.image.toolkit.fluxcd.io,imagerepositories.image.toolkit.fluxcd.io,imageupdateautomations.image.toolkit.fluxcd.io,kustomizations.kustomize.toolkit.fluxcd.io,ocirepositories.source.toolkit.fluxcd.io,providers.notification.toolkit.fluxcd.io,receivers.notification.toolkit.fluxcd.io \
    -A || true
}

create_kind_cluster() {
  log_info "Creating kind cluster ${CLUSTER_NAME}"

  if kind get clusters | grep -q "${CLUSTER_NAME}"; then
    log_error "kind cluster ${CLUSTER_NAME} already exists"
    exit 1
  fi

  kind create cluster \
    --name="${CLUSTER_NAME}" \
    --config="${SCRIPT_DIR}/kind.yaml" \
    --image="kindest/node:${K8S_VERSION}" \
    --wait=60s

  CLUSTER_CREATED=true
  echo
}

install_flux_crds() {
  log_info "Installing Flux CRDs from ${FLUX_CRD_KUSTOMIZATION_URL}"
  kubectl apply -k "github.com/fluxcd/flux2/manifests/crds?ref=main"

  for crd in \
    alerts.notification.toolkit.fluxcd.io \
    artifactgenerators.source.extensions.fluxcd.io \
    buckets.source.toolkit.fluxcd.io \
    externalartifacts.source.toolkit.fluxcd.io \
    gitrepositories.source.toolkit.fluxcd.io \
    helmcharts.source.toolkit.fluxcd.io \
    helmreleases.helm.toolkit.fluxcd.io \
    helmrepositories.source.toolkit.fluxcd.io \
    imagepolicies.image.toolkit.fluxcd.io \
    imagerepositories.image.toolkit.fluxcd.io \
    imageupdateautomations.image.toolkit.fluxcd.io \
    kustomizations.kustomize.toolkit.fluxcd.io \
    ocirepositories.source.toolkit.fluxcd.io \
    providers.notification.toolkit.fluxcd.io \
    receivers.notification.toolkit.fluxcd.io; do
    kubectl wait --for=condition=Established --timeout=120s "crd/${crd}"
  done

  echo
}

ensure_namespace() {
  log_info "Ensuring namespace ${E2E_NAMESPACE} exists"
  kubectl get namespace "${E2E_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${E2E_NAMESPACE}"
  echo
}

install_chart() {
  local helm_args=(
    upgrade
    --install
    "${RELEASE_NAME}"
    "${ROOT_DIR}"
    --namespace "${E2E_NAMESPACE}"
    -f "${ROOT_DIR}/${VALUES_FILE}"
    --wait
    --timeout 300s
  )

  if [ "$#" -gt 0 ]; then
    helm_args+=("$@")
  fi

  log_info "Building chart dependencies"
  helm dependency build "${ROOT_DIR}"
  echo

  log_info "Installing chart with Helm"
  helm "${helm_args[@]}"
  echo
}

verify_release_resources() {
  log_info "Verifying installed Flux resources"
  kubectl -n "${E2E_NAMESPACE}" get alert e2e-alert
  kubectl -n "${E2E_NAMESPACE}" get artifactgenerator e2e-artifact-generator
  kubectl -n "${E2E_NAMESPACE}" get bucket e2e-bucket
  kubectl -n "${E2E_NAMESPACE}" get externalartifact e2e-external-artifact
  kubectl -n "${E2E_NAMESPACE}" get gitrepository e2e-git
  kubectl -n "${E2E_NAMESPACE}" get helmchart e2e-chart
  kubectl -n "${E2E_NAMESPACE}" get helmrelease e2e-release
  kubectl -n "${E2E_NAMESPACE}" get helmrepository e2e-helmrepo
  kubectl -n "${E2E_NAMESPACE}" get imagepolicy e2e-image-policy
  kubectl -n "${E2E_NAMESPACE}" get imagerepository e2e-image-repo
  kubectl -n "${E2E_NAMESPACE}" get imageupdateautomation e2e-image-automation
  kubectl -n "${E2E_NAMESPACE}" get kustomization e2e-kustomization
  kubectl -n "${E2E_NAMESPACE}" get ocirepository e2e-oci
  kubectl -n "${E2E_NAMESPACE}" get provider e2e-provider
  kubectl -n "${E2E_NAMESPACE}" get receiver e2e-receiver
  echo
}

parse_args() {
  for arg in "$@"; do
    case "${arg}" in
      -h|--help)
        show_help
        exit 0
        ;;
    esac
  done
}

main() {
  parse_args "$@"
  verify_prerequisites

  trap cleanup EXIT

  create_kind_cluster
  install_flux_crds
  ensure_namespace
  install_chart "$@"
  verify_release_resources

  log_info "End-to-end checks completed successfully"
}

main "$@"
