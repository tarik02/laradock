FROM docker.elastic.co/elasticsearch/elasticsearch:5.4.1

RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install \
	http://dl.bintray.com/content/imotov/elasticsearch-plugins/org/elasticsearch/elasticsearch-analysis-morphology/5.4.1/elasticsearch-analysis-morphology-5.4.1.zip

RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment

RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-ukrainian

EXPOSE 9200 9300
