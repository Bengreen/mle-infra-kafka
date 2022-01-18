{{- if .Values.kafkaTopics.topics -}}
{{- $scriptHash := include (print $.Template.BasePath "/kafka-topics-script.yaml") . | sha256sum | trunc 8 -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ template "infra-kafka.fullname" . }}-kafka-topics-{{ $scriptHash }}"
  labels:
  {{- include "infra-kafka.labels" . | nindent 4 }}
spec:
  backoffLimit: {{ .Values.kafkaTopics.backoffLimit }}
  template:
    metadata:
      labels:
      {{- include "infra-kafka.selectorLabels" . | nindent 8 }}
    spec:
      restartPolicy: OnFailure
      volumes:
        - name: config-volume
          configMap:
            name: {{ template "infra-kafka.fullname" . }}-kafka-topics
            defaultMode: 0744
      containers:
        - name: {{ template "infra-kafka.fullname" . }}-config
          image: "{{ .Values.kafkaTopics.image }}:{{ .Values.kafkaTopics.imageTag }}"
          command: ["/usr/local/script/runtimeConfig.sh"]
          {{ with .Values.kafkaTopics.resources }}
          resources:
          {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: config-volume
              mountPath: "/usr/local/script"
{{- end -}}