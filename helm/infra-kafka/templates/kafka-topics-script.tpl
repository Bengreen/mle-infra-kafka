{{- if .Values.kafkaTopics.topics -}}
{{- $zk := include "zookeeper.url" (merge (dict "Values" .Values.kafka)) -}}
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
  {{- include "infra-kafka.labels" . | nindent 4 }}
  name: {{ template "infra-kafka.fullname" . }}-kafka-topics
data:
  runtimeConfig.sh: |
    #!/bin/bash
    set -e
    cd /usr/bin
    until kafka-configs --zookeeper {{ $zk }} --entity-type topics --describe || (( count++ >= 6 ))
    do
      echo "Waiting for ZooKeeper..."
      sleep 20
    done
    # expected='0,1,2,3,...,n,'
    # the trailing comma is significant
    expected='{{ until (int .Values.kafka.replicas) | join "," | trim }},'
    connected_brokers=''
    until [[ "$connected_brokers" == "$expected" ]]
    do
      echo "Waiting for all Kafka brokers to be connected to ZooKeeper..."
      connected_brokers=$(zookeeper-shell {{ $zk }} ls /brokers/ids | \
        # brokers formatted as: [ 0, 1, 2 ]
        tail -1 | \
        # broker ids separated by newline
        grep -o '[0-9]\+' | \
        # they may have connected in a random order
        sort | \
        # trim the leading and trailing whitespace
        sed 's/ *$//' | \
        # Replace newline with comma
        # The result has a trailing comma
        tr '\n' ','
        )
      echo "Currently available brokers: $connected_brokers"
      echo "Expected brokers: $expected"
      sleep 20
    done
    echo "Applying runtime configuration using {{ .Values.kafkaTopics.image }}:{{ .Values.kafkaTopics.imageTag }}"
  {{- range $n, $topic := .Values.kafkaTopics.topics }}
    {{- if and $topic.partitions $topic.replicationFactor $topic.reassignPartitions }}
    cat << EOF > {{ $topic.name }}-increase-replication-factor.json
      {"version":1, "partitions":[
        {{- $partitions := (int $topic.partitions) }}
        {{- $replicas := (int $topic.replicationFactor) }}
        {{- range $i := until $partitions }}
          {"topic":"{{ $topic.name }}","partition":{{ $i }},"replicas":[{{- range $j := until $replicas }}{{ $j }}{{- if ne $j (sub $replicas 1) }},{{- end }}{{- end }}]}{{- if ne $i (sub $partitions 1) }},{{- end }}
        {{- end }}
      ]}
    EOF
    kafka-reassign-partitions --zookeeper {{ $zk }} --reassignment-json-file {{ $topic.name }}-increase-replication-factor.json --execute
    kafka-reassign-partitions --zookeeper {{ $zk }} --reassignment-json-file {{ $topic.name }}-increase-replication-factor.json --verify
    {{- else if and $topic.partitions $topic.replicationFactor }}
    kafka-topics --zookeeper {{ $zk }} --create --if-not-exists --force --topic {{ $topic.name }} --partitions {{ $topic.partitions }} --replication-factor {{ $topic.replicationFactor }}
    {{- else if $topic.partitions }}
    kafka-topics --zookeeper {{ $zk }} --alter --force --topic {{ $topic.name }} --partitions {{ $topic.partitions }} || true
    {{- end }}
    {{- if $topic.defaultConfig }}
    kafka-configs --zookeeper {{ $zk }} --entity-type topics --entity-name {{ $topic.name }} --alter --force --delete-config {{ nospace $topic.defaultConfig }} || true
    {{- end }}
    {{- if $topic.config }}
    kafka-configs --zookeeper {{ $zk }} --entity-type topics --entity-name {{ $topic.name }} --alter --force --add-config {{ nospace $topic.config }}
    {{- end }}
    kafka-configs --zookeeper {{ $zk }} --entity-type topics --entity-name {{ $topic.name }} --describe
    {{- if $topic.acls }}
      {{- range $a, $acl := $topic.acls }}
        {{ if and $acl.user $acl.operations }}
    kafka-acls --authorizer-properties zookeeper.connect={{ $zk }} --force --add --allow-principal User:{{ $acl.user }}{{- range $operation := $acl.operations }} --operation {{ $operation }} {{- end }} --topic {{ $topic.name }} {{ $topic.extraParams }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

    if curl -s -X POST --output /dev/null http://localhost:15020/quitquitquit ; then
      echo "Closed Envoy proxy"
    else
      echo "No Envoy found or failed to find envoy to close"
    fi
{{- end -}}