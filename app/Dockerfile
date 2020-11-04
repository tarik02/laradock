ARG LARADOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest
FROM laradock/workspace:${BASE_IMAGE_TAG_PREFIX}-${LARADOCK_PHP_VERSION}

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

ARG LARADOCK_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

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

# Install composer 1
RUN rm -f /usr/local/bin/composer && \
	curl -s http://getcomposer.org/installer | php -- --version=1.10.17 && \
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
# Python 3:
###########################################################################

USER root

ARG INSTALL_PYTHON=false

RUN set -xe; \
	if [ ${INSTALL_PYTHON} = true ]; then \
		apt-get -y install python3 python3-dev python3-setuptools build-essential \
			&& curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
			&& python3 get-pip.py \
			&& python3 -m pip install --upgrade pip  \
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
			&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
			&& apt-get update \
			&& apt-get install docker-ce-cli \
			# install docker-compose
			&& curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
			&& chmod +x /usr/local/bin/docker-compose \
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

USER laradock
STOPSIGNAL SIGQUIT
CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 9000
