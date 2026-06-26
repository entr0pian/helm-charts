{{/*
Render the backend service endpoint.
The operator creates the service as <cr-name>-backend on port 80.
Usage: {{ include "taskapp-backend.endpoint" . }}
*/}}
{{- define "taskapp-backend.endpoint" -}}
{{- printf "http://%s-backend:80" .Release.Name }}
{{- end }}
