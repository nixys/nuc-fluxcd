{{- define "nuc-fluxcd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-fluxcd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-fluxcd.labels" -}}
app.kubernetes.io/name: {{ include "nuc-fluxcd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "nuc-fluxcd.chart" . }}
{{- end -}}

{{- define "nuc-fluxcd.renderResource" -}}
{{- $root := .root -}}
{{- $item := .item -}}
{{- $resourceName := .resourceName -}}
{{- $defaultLabels := include "nuc-fluxcd.labels" $root | fromYaml -}}
{{- $labels := mustMergeOverwrite (dict) $defaultLabels ($root.Values.commonLabels | default dict) ($item.labels | default dict) -}}
{{- $annotations := mustMergeOverwrite (dict) ($root.Values.commonAnnotations | default dict) ($item.annotations | default dict) -}}
{{- if ne $resourceName "__helm_docs_example__" }}
apiVersion: {{ default .defaultApiVersion $item.apiVersion }}
kind: {{ .kind }}
metadata:
  name: {{ $resourceName }}
  {{- if .namespaced }}
  namespace: {{ default $root.Release.Namespace $item.namespace }}
  {{- end }}
  labels:
{{ toYaml $labels | nindent 4 }}
  {{- if $annotations }}
  annotations:
{{ toYaml $annotations | nindent 4 }}
  {{- end }}
{{- with $item.spec }}
spec:
{{ toYaml . | nindent 2 }}
{{- end }}
{{- with $item.status }}
status:
{{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}
{{- define "nuc-fluxcd.renderResources" -}}
{{- $collection := .collection | default dict -}}
{{- $documents := list -}}
{{- range $resourceName := keys $collection | sortAlpha }}
{{- $item := get $collection $resourceName -}}
{{- if kindIs "map" $item }}
{{- $document := include "nuc-fluxcd.renderResource" (dict
  "root" $.root
  "item" $item
  "resourceName" $resourceName
  "kind" $.kind
  "defaultApiVersion" $.defaultApiVersion
  "namespaced" $.namespaced
) -}}
{{- if $document }}
{{- $documents = append $documents $document -}}
{{- end }}
{{- end }}
{{- end }}
{{- join "\n---\n" $documents -}}
{{- end -}}
