#!/bin/bash

# Start crond in background
sudo cron -l

# Fix owner
sudo chown laradock:laradock /opt/persist
sudo chown laradock:laradock /home/laradock/.vscode-server

# Start php-fpm in background

while true; do
	bash -c "php-fpm$LARADOCK_PHP_VERSION" &
	FPM_PID=$!

	sudo touch /tmp/restart-fpm
	while [ -f /tmp/restart-fpm ]; do
		sleep 0.1
	done

	sudo rm -f /tmp/restart-fpm
	kill -QUIT $FPM_PID
done
