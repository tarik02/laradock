ARG ELK_VERSION
FROM docker.elastic.co/kibana/kibana:${ELK_VERSION}

ARG KIBANA_HOST
ARG ELASTICSEARCH_HOST

RUN echo -e "#\n\
server.name: ${KIBANA_HOST}\n\
server.host: \"0\"\n\
elasticsearch.hosts: [ "http://${ELASTICSEARCH_HOST}:9200" ]\n" | tee /usr/share/kibana/config/kibana.yml

EXPOSE 5601
