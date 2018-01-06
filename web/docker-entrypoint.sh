#!/bin/bash

cd /var/www
/usr/bin/lapis migrate
/usr/bin/lapis server development
