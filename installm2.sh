#!/bin/sh
service mysql restart && service apache2 restart && exec "$@"
