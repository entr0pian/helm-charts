{{/* Every resource is named after the Helm release: <component>-schema. */}}
{{- define "database-schema.secretName" -}}
{{ .Release.Name }}-database
{{- end -}}

{{- define "database-schema.configMapName" -}}
{{ .Release.Name }}-migrations
{{- end -}}

{{- define "database-schema.labels" -}}
app.kubernetes.io/name: database-schema
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.platform.component }}
platform.taskapp.io/component: {{ . | quote }}
{{- end }}
{{- with .Values.platform.environment }}
platform.taskapp.io/environment: {{ . | quote }}
{{- end }}
{{- end -}}

{{/* The service commit, for the portal; annotation since a SHA can exceed label limits. */}}
{{- define "database-schema.annotations" -}}
{{- with .Values.version }}
platform.taskapp.io/schema-version: {{ . | quote }}
{{- end }}
{{- end -}}
