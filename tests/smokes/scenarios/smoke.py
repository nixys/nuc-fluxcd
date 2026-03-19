from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from tests.smokes.steps import chart, helm, kubeconform, render, system


@dataclass
class SmokeContext:
    repo_root: Path
    workdir: Path
    chart_dir: Path
    render_dir: Path
    release_name: str
    namespace: str
    kube_version: str
    kubeconform_bin: str
    schema_location: str
    skip_kinds: str

    @property
    def example_values(self) -> Path:
        return self.repo_root / "values.yaml.example"

    @property
    def rendering_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "rendering-contract.values.yaml"

    @property
    def invalid_list_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "invalid-list-contract.values.yaml"


def check_default_empty(context: SmokeContext) -> None:
    helm.lint(context.chart_dir, workdir=context.workdir)
    output_path = context.render_dir / "default-empty.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        output_path=output_path,
        workdir=context.workdir,
    )
    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 0)


def check_schema_invalid_list_contract(context: SmokeContext) -> None:
    result = helm.lint(
        context.chart_dir,
        values_file=context.invalid_list_contract_values,
        workdir=context.workdir,
        check=False,
    )
    if result.returncode == 0:
        raise system.TestFailure(
            "helm lint unexpectedly succeeded for invalid list-based values"
        )

    combined_output = f"{result.stdout}\n{result.stderr}"
    if "gitRepositories" not in combined_output or "object" not in combined_output:
        raise system.TestFailure(
            "helm lint failed for invalid values, but the error does not mention the object-based map contract"
        )


def check_rendering_contract(context: SmokeContext) -> None:
    helm.lint(
        context.chart_dir,
        values_file=context.rendering_contract_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / "rendering-contract.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.rendering_contract_values,
        output_path=output_path,
        workdir=context.workdir,
    )

    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 2)

    git_repository = render.select_document(
        documents, kind="GitRepository", name="platform-config"
    )
    render.assert_path(git_repository, "apiVersion", "example.net/v1alpha1")
    render.assert_path(git_repository, "metadata.namespace", context.namespace)
    render.assert_path(
        git_repository,
        "metadata.labels[app.kubernetes.io/name]",
        "flux-platform",
    )
    render.assert_path(git_repository, "metadata.labels.platform", "flux")
    render.assert_path(git_repository, "metadata.labels.component", "source")
    render.assert_path(git_repository, "metadata.labels.tier", "control-plane")
    render.assert_path(git_repository, "metadata.annotations.team", "platform")
    render.assert_path(git_repository, "metadata.annotations.note", "gitops")
    render.assert_path(
        git_repository, "spec.url", "https://github.com/example/platform-config"
    )

    helm_release = render.select_document(
        documents, kind="HelmRelease", name="platform-release"
    )
    render.assert_path(helm_release, "apiVersion", "helm.toolkit.fluxcd.io/v2beta2")
    render.assert_path(helm_release, "metadata.namespace", "release-space")
    render.assert_path(
        helm_release,
        "metadata.labels[app.kubernetes.io/name]",
        "flux-platform",
    )
    render.assert_path(helm_release, "metadata.labels.component", "release")
    render.assert_path(helm_release, "metadata.annotations.team", "platform")
    render.assert_path(helm_release, "metadata.annotations.note", "promoted")
    render.assert_path(helm_release, "spec.releaseName", "platform")


def check_example_render(context: SmokeContext) -> None:
    helm.lint(
        context.chart_dir,
        values_file=context.example_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / "example-render.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.example_values,
        output_path=output_path,
        workdir=context.workdir,
    )

    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 15)
    render.assert_kinds(
        documents,
        {
            "Alert",
            "ArtifactGenerator",
            "Bucket",
            "ExternalArtifact",
            "GitRepository",
            "HelmChart",
            "HelmRelease",
            "HelmRepository",
            "ImagePolicy",
            "ImageRepository",
            "ImageUpdateAutomation",
            "Kustomization",
            "OCIRepository",
            "Provider",
            "Receiver",
        },
    )

    git_repository = render.select_document(
        documents, kind="GitRepository", name="platform-config"
    )
    render.assert_path(git_repository, "metadata.namespace", "flux-system")

    helm_release = render.select_document(documents, kind="HelmRelease", name="podinfo")
    render.assert_path(
        helm_release, "spec.chart.spec.sourceRef.name", "podinfo"
    )
    render.assert_path(helm_release, "spec.values.replicaCount", 2)

    image_policy = render.select_document(
        documents, kind="ImagePolicy", name="podinfo-policy"
    )
    render.assert_path(image_policy, "spec.policy.semver.range", "6.x")

    receiver = render.select_document(documents, kind="Receiver", name="github-receiver")
    render.assert_path(receiver, "spec.events[1]", "push")

    artifact_generator = render.select_document(
        documents, kind="ArtifactGenerator", name="platform-artifacts"
    )
    render.assert_path(artifact_generator, "spec.sources[1].name", "podinfo-oci")


def check_example_kubeconform(context: SmokeContext) -> None:
    output_path = context.render_dir / "example-kubeconform.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.example_values,
        output_path=output_path,
        workdir=context.workdir,
    )
    kubeconform.validate(
        manifest_path=output_path,
        kube_version=context.kube_version,
        kubeconform_bin=context.kubeconform_bin,
        schema_location=context.schema_location,
        skip_kinds=context.skip_kinds,
    )


SCENARIOS: list[tuple[str, Callable[[SmokeContext], None]]] = [
    ("default-empty", check_default_empty),
    ("schema-invalid-list-contract", check_schema_invalid_list_contract),
    ("rendering-contract", check_rendering_contract),
    ("example-render", check_example_render),
    ("example-kubeconform", check_example_kubeconform),
]


def run_smoke_suite(args) -> int:
    scenario_map = dict(SCENARIOS)
    requested = args.scenario or ["all"]
    if "all" in requested:
        selected = [name for name, _ in SCENARIOS]
    else:
        selected = requested

    repo_root = Path(args.chart_dir).resolve()
    workdir, chart_dir = chart.stage_chart(repo_root, args.workdir)
    context = SmokeContext(
        repo_root=repo_root,
        workdir=workdir,
        chart_dir=chart_dir,
        render_dir=workdir / "rendered",
        release_name=args.release_name,
        namespace=args.namespace,
        kube_version=args.kube_version,
        kubeconform_bin=args.kubeconform_bin,
        schema_location=args.schema_location,
        skip_kinds=args.skip_kinds,
    )
    context.render_dir.mkdir(parents=True, exist_ok=True)

    failures: list[tuple[str, str]] = []
    try:
        for name in selected:
            system.log(f"=== scenario: {name} ===")
            try:
                scenario_map[name](context)
            except Exception as exc:
                failures.append((name, str(exc)))
                system.log(f"FAILED: {name}: {exc}")
            else:
                system.log(f"PASSED: {name}")
    finally:
        if args.keep_workdir:
            system.log(f"workdir kept at {workdir}")
        else:
            chart.cleanup(workdir)

    if failures:
        system.log("=== summary: failures ===")
        for name, message in failures:
            system.log(f"- {name}: {message}")
        return 1

    system.log("=== summary: all smoke scenarios passed ===")
    return 0
