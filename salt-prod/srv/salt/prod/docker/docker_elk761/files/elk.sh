#!/bin/sh
# elasticsearch start shell
docker run -d --restart=always --name=elasticsearch  \
-p 9200:9200 \
-p 5601:5601 \
-e ES_CONNECT_RETRY=90 \
-e KIBANA_CONNECT_RETRY=90 \
-e LOGSTASH_START=0 \
-e ELASTICSEARCH_START=1 \
-e KIBANA_START=1 \
-e ES_HEAP_SIZE="4g" \
-e TZ="Asia/Shanghai" \
-v /data/elk/kibana.yml:/opt/kibana/config/kibana.yml \
-v /data/elk/elasticsearch.yml:/etc/elasticsearch/elasticsearch.yml \
-v /data/elk/es_data:/var/lib/elasticsearch \
-v /data/elk/es_snapshot:/var/backups \
192.168.13.235:8000/ops/elk:761
