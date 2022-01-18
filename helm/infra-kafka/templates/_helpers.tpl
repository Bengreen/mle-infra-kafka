{{- define "infra-kafka.ml8sversion" -}}
{{- range $dependency := .Chart.Dependencies -}}
{{- if eq $dependency.Name "ml8scommon" -}}{{ $dependency.Version }}{{- end -}}
{{- end -}}
{{- end -}}

{{- define "infra-kafka.fullname" -}}
{{- $ml8sFullname := print "ml8scommon.fullname-" (include "infra-kafka.ml8sversion" .) -}}
{{ include $ml8sFullname . }}
{{- end -}}

{{- define "infra-kafka.labels" -}}
{{- $ml8sLabels := print "ml8scommon.labels-" (include "infra-kafka.ml8sversion" .) -}}
{{ include $ml8sLabels . }}
{{- end -}}

{{- define "infra-kafka.configmaps" -}}
{{ include (print "ml8scommon.configmaps-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}


{{- define "infra-kafka.defineVolumes" -}}
{{ include (print "ml8scommon.defineVolumes-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.defineVolumeMounts" -}}
{{ include (print "ml8scommon.defineVolumeMounts-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.env" -}}
{{ include (print "ml8scommon.env-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.dockerImage" -}}
{{ include (print "ml8scommon.dockerImage-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.selectorLabels" -}}
{{ include (print "ml8scommon.selectorLabels-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.imagePullSecrets" -}}
{{ include (print "ml8scommon.imagePullSecrets-" (include "infra-kafka.ml8sversion" .)) . }}
{{- end -}}

{{- define "infra-kafka.secrets" -}}
{{- $ml8sSecrets := print "ml8scommon.secrets-" (include "infra-kafka.ml8sversion" .) -}}
{{ include $ml8sSecrets . }}
{{- end -}}

{{- define "infra-kafka.topiclist" -}}
{{- range .Values.kafka.topics }} {{ .name }}{{- end -}}
{{- end -}}

{{- define "infra-kafka.zk-name" -}}
{{- .Values.kafka.zookeeper.fullnameOverride -}}
{{- end -}}

{{- define "infra-kafka.kafka-name" -}}
{{- .Values.kafka.fullnameOverride -}}
{{- end -}}


{{- define "csurv.keycloak.fullname" -}}
{{ .Release.Name }}-keycloak
{{- end -}}

{{- define "infra-kafka.grafanadashboards" -}}
{{- $ml8sDashboards := print "ml8scommon.grafanadashboards-" (include "infra-kafka.ml8sversion" .) -}}
{{ include $ml8sDashboards . }}
{{- end -}}