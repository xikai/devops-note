FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.15

#https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v5.6.15/elasticsearch-analysis-ik-5.6.15.zip
RUN elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v5.6.15/elasticsearch-analysis-ik-5.6.15.zip

COPY ./config/*.txt /usr/share/elasticsearch/config/
