FROM phusion/baseimage:master

LABEL maintainer="Tarik02 <Taras.Fomin@gmail.com>"

ARG LARADOCK_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# If you're in China, or you need to change sources, will be set CHANGE_SOURCE to true in .env.

ARG CHANGE_SOURCE=false
RUN if [ ${CHANGE_SOURCE} = true ]; then \
	# Change application source from deb.debian.org to aliyun source
	sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
	sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
	sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
;fi

# Start as root
USER root

# Add the "PHP" ppa
RUN apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:ondrej/php

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf

# Install "PHP Extentions", "libraries", "Software's"
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
		php${LARADOCK_PHP_VERSION}-cli \
		php${LARADOCK_PHP_VERSION}-common \
		php${LARADOCK_PHP_VERSION}-curl \
		php${LARADOCK_PHP_VERSION}-intl \
		php${LARADOCK_PHP_VERSION}-json \
		php${LARADOCK_PHP_VERSION}-xml \
		php${LARADOCK_PHP_VERSION}-mbstring \
		php${LARADOCK_PHP_VERSION}-mysql \
		php${LARADOCK_PHP_VERSION}-pgsql \
		php${LARADOCK_PHP_VERSION}-sqlite \
		php${LARADOCK_PHP_VERSION}-sqlite3 \
		php${LARADOCK_PHP_VERSION}-zip \
		php${LARADOCK_PHP_VERSION}-bcmath \
		php${LARADOCK_PHP_VERSION}-memcached \
		php${LARADOCK_PHP_VERSION}-gd \
		php${LARADOCK_PHP_VERSION}-dev \
		pkg-config \
		libcurl4-openssl-dev \
		libedit-dev \
		libssl-dev \
		libxml2-dev \
		xz-utils \
		libsqlite3-dev \
		rsync \
		sqlite3 \
		git \
		curl \
		vim \
		nano \
		tree \
		postgresql-client \
	&& apt-get clean

###########################################################################
# Laradock non-root user:
###########################################################################

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

ARG CHANGE_SOURCE=false
ARG UBUNTU_SOURCE
COPY ./app/bin/sources.sh /tmp/sources.sh

RUN if [ ${CHANGE_SOURCE} = true ]; then \
	chmod +x /tmp/sources.sh && \
	/bin/sh -c /tmp/sources.sh && \
	rm -rf /tmp/sources.sh \
;fi

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
	apt-get update -yqq && \
	pecl channel-update pecl.php.net && \
	groupadd -g ${PGID} laradock && \
	useradd -u ${PUID} -g laradock -m laradock -G docker_env && \
	usermod -p "*" laradock -s /bin/bash && \
	apt-get install -yqq \
	  apt-utils \
	  #
	  #--------------------------------------------------------------------------
	  # Mandatory Software's Installation
	  #--------------------------------------------------------------------------
	  #
	  # Mandatory Software's such as ("php-cli", "git", "vim", ....) are
	  # installed on the base image 'laradock/workspace' image. If you want
	  # to add more Software's or remove existing one, you need to edit the
	  # base image (https://github.com/Laradock/workspace).
	  #
	  # next lines are here because there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
	  libzip-dev zip unzip \
	  # Install the zip extension
	  php${LARADOCK_PHP_VERSION}-zip \
	  # nasm
	  nasm && \
	  php -m | grep -q 'zip'

# install fpm
RUN set -xe; \
	apt-get install -yqq php${LARADOCK_PHP_VERSION}-fpm sudo cron


USER laradock

# add ~/.local/bin to PATH
RUN mkdir -p ~/.local/bin && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#

###########################################################################
# Set Timezone
###########################################################################

USER root

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


###########################################################################
# Composer:
###########################################################################

USER root

# Install composer
RUN rm -f /usr/local/bin/composer && \
	curl -s http://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer


USER laradock

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
	echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc


###########################################################################
# Crontab
###########################################################################

USER root

RUN set -xe; \
	mkdir -p /etc/cron.d; \
	chmod -R 644 /etc/cron.d


###########################################################################
# xDebug:
###########################################################################

USER root

ARG INSTALL_XDEBUG=false

COPY ./app/php/xdebug.ini /opt/xdebug.ini

RUN set -xe; \
	if [ ${INSTALL_XDEBUG} = true ]; then \
		# Load the xdebug extension only with phpunit commands
		apt-get install -y php${LARADOCK_PHP_VERSION}-xdebug \
			&& sed -i 's/^;//g' /etc/php/${LARADOCK_PHP_VERSION}/cli/conf.d/20-xdebug.ini \
			# Disable xdebug by default
			&& sed -i 's/^zend_extension=/;zend_extension=/g' /etc/php/$LARADOCK_PHP_VERSION/fpm/conf.d/20-xdebug.ini \
			&& sed -i 's/^zend_extension=/;zend_extension=/g' /etc/php/$LARADOCK_PHP_VERSION/cli/conf.d/20-xdebug.ini \
			&& ln -s /opt/xdebug.ini /etc/php/${LARADOCK_PHP_VERSION}/cli/conf.d/xdebug.ini \
			&& ln -s /opt/xdebug.ini /etc/php/${LARADOCK_PHP_VERSION}/fpm/conf.d/xdebug.ini \
	;fi

###########################################################################
# Node / FNM / Yarn:
###########################################################################

USER laradock

ARG INSTALL_NODE=false
ARG INSTALL_YARN=false

RUN set -xe; \
	if [ ${INSTALL_NODE} = true ]; then \
		# Install fnm (A Node Version Manager) and a few NodeJS versions
		curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell \
			&& $HOME/.fnm/fnm install 10 \
			&& $HOME/.fnm/fnm install 12 \
			&& $HOME/.fnm/fnm install 14 \
			&& $HOME/.fnm/fnm default 14 \
			&& eval "$($HOME/.fnm/fnm env)" \
			&& $HOME/.fnm/fnm use 14 \
			&& echo "# NPM bin" >> ~/.bashrc \
			&& echo "export PATH=\"$(npm bin --global):$PATH\"" >> ~/.bashrc \
	;fi

RUN set -xe; \
	if [ ${INSTALL_YARN} = true ]; then \
		eval "$($HOME/.fnm/fnm env)" \
			&& $HOME/.fnm/fnm use 14 \
			&& curl -o- -L https://yarnpkg.com/install.sh | bash \
			&& echo "# Yarn bin" >> ~/.bashrc \
			&& echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc \
	;fi


###########################################################################
# Python 2:
###########################################################################

USER root

ARG INSTALL_PYTHON27=false

RUN set -xe; \
	if [ ${INSTALL_PYTHON27} = true ]; then \
		apt-get -y install python2.7 python2.7-dev \
			&& update-alternatives --install /usr/bin/python2 python2 /usr/bin/python2.7 2 \
	;fi


###########################################################################
# Python 3:
###########################################################################

USER root

ARG INSTALL_PYTHON=false

RUN set -xe; \
	if [ ${INSTALL_PYTHON} = true ]; then \
		apt-get -y install python3 python3-dev python3-setuptools build-essential \
			&& curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
			&& python3 get-pip.py \
			&& rm get-pip.py \
			&& python3 -m pip install --upgrade pip \
			&& python3 -m pip install --upgrade virtualenv \
	;fi


###########################################################################
# Docker:
###########################################################################

USER root

ARG INSTALL_DOCKER=false

RUN set -xe; \
	if [ ${INSTALL_DOCKER} = true ]; then \
		# install docker
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
			&& add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
			&& apt-get update \
			&& apt-get install docker-ce-cli \
			# install docker-compose
			;if [[ $(uname -m) == "x86_64" ]]; then \
				curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
					&& chmod +x /usr/local/bin/docker-compose \
			;fi \
	;fi

ARG DOCKER_GID

RUN set-xe; \
	if [ ! -z ${DOCKER_GID} ]; then \
		groupadd -for -g ${DOCKER_GID} docker \
			&& usermod -aG docker laradock \
	;fi


###########################################################################
# Dockvalet:
###########################################################################

USER root

ARG APP_CODE_PATH_CONTAINER=
ARG INSTALL_DOCKVALET=true
RUN set -xe; \
	if [ ${INSTALL_DOCKVALET} = true ]; then \
		git clone --recursive https://github.com/Tarik02/dockvalet.git /opt/dockvalet \
			&& chown laradock:laradock -R /opt/dockvalet \
			&& mkdir /opt/dockvalet/.config \
			&& chown laradock:laradock -R /opt/dockvalet/.config \
			&& echo "{\"tld\":\"test\",\"paths\":[\"${APP_CODE_PATH_CONTAINER}\"]}" > /opt/dockvalet/.config/config.json \
			&& chown laradock:laradock -R /opt/dockvalet/.config/config.json \
	;fi


###########################################################################
# Laradock CLI:
###########################################################################

USER laradock

ARG INSTALL_LARADOCK_CLI=false
ENV LARADOCK_ROOT=${APP_CODE_PATH_CONTAINER}
ENV LARADOCK_CLI=/opt/laradock-cli.py

USER root
RUN touch ${LARADOCK_CLI} && chown laradock:laradock ${LARADOCK_CLI}

USER laradock
RUN set -xe; \
	if [ ${INSTALL_LARADOCK_CLI} = true ]; then \
		if [ ${INSTALL_PYTHON} != true ]; then \
			echo 'Laradock CLI requires python to be installed' > /dev/stderr \
			exit 1 \
		;fi \
			&& if [ ${INSTALL_DOCKER} != true ]; then \
			echo 'Laradock CLI requires docker to be installed' > /dev/stderr \
			exit 1 \
		;fi \
			&& python3 -m pip install python-dotenv \
			&& curl -fsSL https://github.com/Tarik02/laradock-cli/raw/master/install.sh | bash \
			&& $HOME/.local/bin/laradock download \
	;fi

###########################################################################
# PHP-FPM:
###########################################################################

USER root

RUN set -eux \
	&& mkdir /var/log/fpm \
	&& cd /etc/php/${LARADOCK_PHP_VERSION}/fpm \
	&& mkdir php-fpm.d \
	&& { \
		echo '[global]'; \
		echo "include=/etc/php/${LARADOCK_PHP_VERSION}/fpm/php-fpm.d/*.conf"; \
		echo "include=/etc/php/${LARADOCK_PHP_VERSION}/fpm/pool.d/*.conf"; \
	} | tee php-fpm.conf \
	&& { \
		echo '[global]'; \
		echo "error_log = /var/log/fpm/${LARADOCK_PHP_VERSION}_error.log"; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo "access.log = /var/log/fpm/${LARADOCK_PHP_VERSION}_access.log"; \
		echo; \
		echo 'listen = 9000'; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/default.conf

COPY ./app/php/www.pool.conf /etc/php/${LARADOCK_PHP_VERSION}/fpm/pool.d/www.conf
RUN mkdir /run/php


###########################################################################
# Install custom things:
###########################################################################

USER root

ADD ./custom/install.d /opt/install.d
RUN set -xe; \
	for i in $(ls /opt/install.d); do \
		bash /opt/install.d/$i; \
	done


###########################################################################
# Clean up:
###########################################################################

USER root

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	rm /var/log/lastlog /var/log/faillog


###########################################################################
# Startup:
###########################################################################

USER laradock
ADD ./app/bin/startup.sh ./app/bin/restart-fpm ./app/bin/xdebug-toggle /opt/

USER root
RUN chmod +x /opt/restart-fpm /opt/xdebug-toggle

RUN set -xe; \
	mkdir -p ${APP_CODE_PATH_CONTAINER}/.laradock; \
	chown laradock:laradock ${APP_CODE_PATH_CONTAINER}; \
	chown laradock:laradock ${APP_CODE_PATH_CONTAINER}/.laradock

USER laradock
STOPSIGNAL SIGQUIT
CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 9000
