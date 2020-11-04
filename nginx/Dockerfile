FROM nginx:alpine

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

# If you're in China, or you need to change sources, will be set CHANGE_SOURCE to true in .env.

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
	# Change application source from dl-cdn.alpinelinux.org to aliyun source
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories \
;fi

RUN apk update \
	&& apk upgrade \
	&& apk --update add logrotate \
	&& apk add --no-cache openssl \
	&& apk add --no-cache bash

RUN apk add --no-cache curl

RUN set -x ; \
	addgroup -g 82 -S www-data ; \
	adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

# Create 'messages' file used from 'logrotate'
RUN touch /var/log/messages

# Copy 'logrotate' config file
COPY logrotate/nginx /etc/logrotate.d/

# Set upstream conf and remove the default conf
RUN rm /etc/nginx/conf.d/default.conf


RUN mkdir /etc/nginx/sites-internal.d /etc/nginx/sites-disabled.d

COPY dockvalet.conf /etc/nginx/sites-disabled.d/

###########################################################################
# Dockvalet:
###########################################################################

USER root

ARG INSTALL_DOCKVALET=true
RUN if [ ${INSTALL_DOCKVALET} = true ]; then \
	cp /etc/nginx/sites-disabled.d/dockvalet.conf /etc/nginx/sites-internal.d/ && \
		mkdir -p /opt/dockvalet && \
		touch /opt/dockvalet/server.php \
;fi


ADD ./startup.sh /opt/startup.sh
CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 80 81 443
