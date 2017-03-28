#!/bin/sh

service mysql restart
service apache2 restart
cd /var/www/html

echo "Installation Done"
exec "$@"
