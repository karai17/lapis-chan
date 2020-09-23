#!/usr/bin/env bash

# Wait for PostgreSQL
/usr/local/bin/wait-for-it.sh psql:5432 -s -q

if [ $? -eq 0 ]; then
	cd /var/www

	# Check if we are executing tests
	if [ "$1" = "test" ]; then
		lapis migrate $1
		busted

	# Run Application normally
	else
		lapis migrate
		lapis server $1
	fi

else
	exit 5432 # PostgreSQL didn't load
fi
