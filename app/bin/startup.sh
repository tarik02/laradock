#!/bin/bash

# Start crond in background
crond -l 2 -b

# Fix owner
sudo chown laradock:laradock /opt/persist

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
