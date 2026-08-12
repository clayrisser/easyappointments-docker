#!/bin/sh

set -e

# PHP needs an explicit date.timezone; honour the standard TZ env var.
printf 'date.timezone = %s\n' "${TZ:-UTC}" \
	>/usr/local/etc/php/conf.d/timezone.ini

# DEBUG is the legacy name for DEBUG_MODE — keep accepting it.
_debug=$(echo "${DEBUG_MODE:-${DEBUG:-false}}" | tr '[:upper:]' '[:lower:]')
_google_sync=$(echo "${GOOGLE_SYNC_FEATURE:-false}" | tr '[:upper:]' '[:lower:]')

cat >/var/www/html/config.php <<EOF
<?php
class Config
{
    // ------------------------------------------------------------------------
    // GENERAL SETTINGS
    // ------------------------------------------------------------------------

    const BASE_URL = '${BASE_URL:-http://localhost}';
    const LANGUAGE = '${LANGUAGE:-english}';
    const DEBUG_MODE = ${_debug};

    // ------------------------------------------------------------------------
    // DATABASE SETTINGS
    // ------------------------------------------------------------------------

    const DB_HOST = '${DB_HOST:-mariadb}';
    const DB_NAME = '${DB_NAME:-easyappointments}';
    const DB_USERNAME = '${DB_USERNAME:-easyappointments}';
    const DB_PASSWORD = '${DB_PASSWORD:-easyappointments}';

    // ------------------------------------------------------------------------
    // GOOGLE CALENDAR SYNC
    // ------------------------------------------------------------------------

    const GOOGLE_SYNC_FEATURE = ${_google_sync};
    const GOOGLE_CLIENT_ID = '${GOOGLE_CLIENT_ID:-}';
    const GOOGLE_CLIENT_SECRET = '${GOOGLE_CLIENT_SECRET:-}';
}
EOF
chown www-data:www-data /var/www/html/config.php

exec "$@"
