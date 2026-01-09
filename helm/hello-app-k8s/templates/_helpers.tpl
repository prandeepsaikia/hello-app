{{- define "hello-app.name" -}}
hello-app
{{- end }}

{{ define "hello-app.fullname" -}}
{{ include "hello-app.name" . }}-{{ .Release.Name }}
{{- end }}

{{ define "hello-app.labels" -}}
app.kubernetes.io/name: {{ include "hello-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

