{{/*
Render the container image string.
Usage: {{ include "taskapp-frontend.image" . }}
*/}}
{{- define "taskapp-frontend.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}
