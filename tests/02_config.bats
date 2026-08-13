#!/usr/bin/env bats
# config.php generation.
#
# The image renders config.php at container start from environment variables.
# These tests pin down that it renders code which *reads* those variables at
# runtime, rather than code which *contains* them: an environment value that
# reaches the PHP parser is a code injection vector, because operators cannot
# be asked to keep quotes out of their passwords.
load helper.sh

# Awkward but entirely legal, and enough on its own to turn a hand-quoted PHP
# string literal into a parse error.
QUOTE_PW="O'Brien#1"

# Crafted to close the string literal, close class Config, run code at file
# scope, then open a second class so the remainder of the template still
# parses -- a config.php that `php -l` accepts and that executes on every
# request.
RCE_PW="x'; } system(\$_GET['c']); class Pwned { const Y = 'z"

# The same injection with a side effect that is trivial to observe.
CANARY_PW="x'; } file_put_contents('/pwned', '1'); class Pwned { const Y = 'z"

@test "a password containing an apostrophe still yields a parsable config" {
	export DB_PASSWORD="$QUOTE_PW"
	run generate_config 'php -l /var/www/html/config.php'
	[ "$status" -eq 0 ]
}

@test "a password carrying a PHP payload is not written into the config" {
	export DB_PASSWORD="$RCE_PW"

	run generate_config 'php -l /var/www/html/config.php'
	[ "$status" -eq 0 ]

	run generate_config 'cat /var/www/html/config.php'
	[ "$status" -eq 0 ]
	! printf '%s' "$output" | grep -q 'system('
	! printf '%s' "$output" | grep -q 'Pwned'
}

@test "executing the generated config runs no injected code" {
	export DB_PASSWORD="$CANARY_PW"
	# `php <file>` parses and executes it exactly as index.php's require_once
	# does. The canary is absent only if nothing from the environment ran.
	run generate_config 'php /var/www/html/config.php >/dev/null 2>&1; [ ! -e /pwned ]'
	[ "$status" -eq 0 ]
}

@test "no environment value reaches the generated PHP source" {
	run generate_config 'sha256sum /var/www/html/config.php'
	[ "$status" -eq 0 ]
	baseline="$output"

	# Every documented variable, each carrying the injection payload. The
	# generated source has to come out byte-for-byte identical to the run
	# above, which is the property that makes the whole class of bug
	# impossible rather than merely escaped.
	export BASE_URL="$RCE_PW"
	export LANGUAGE="$RCE_PW"
	export DEBUG_MODE="$RCE_PW"
	export DEBUG="$RCE_PW"
	export DB_HOST="$RCE_PW"
	export DB_NAME="$RCE_PW"
	export DB_USERNAME="$RCE_PW"
	export DB_PASSWORD="$RCE_PW"
	export GOOGLE_SYNC_FEATURE="$RCE_PW"
	export GOOGLE_CLIENT_ID="$RCE_PW"
	export GOOGLE_CLIENT_SECRET="$RCE_PW"
	export CONFIG_ENV="BASE_URL LANGUAGE DEBUG_MODE DEBUG DB_HOST DB_NAME DB_USERNAME DB_PASSWORD GOOGLE_SYNC_FEATURE GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET"

	run generate_config 'sha256sum /var/www/html/config.php'
	[ "$status" -eq 0 ]
	[ "$output" = "$baseline" ]
}

@test "configuration still reaches the application" {
	# Guards the test above: a config.php that ignored the environment
	# entirely would satisfy it, and would also be useless.
	export DB_PASSWORD="$RCE_PW"
	export BASE_URL="https://appointments.example.com"
	export LANGUAGE="french"
	export DEBUG_MODE="true"
	export CONFIG_ENV="DB_PASSWORD BASE_URL LANGUAGE DEBUG_MODE"

	run generate_config 'php -r "
		require \"/var/www/html/config.php\";
		exit(
			Config::DB_PASSWORD === getenv(\"DB_PASSWORD\")
			&& Config::BASE_URL === \"https://appointments.example.com\"
			&& Config::LANGUAGE === \"french\"
			&& Config::DEBUG_MODE === true
			&& Config::DB_HOST === \"mariadb\"
				? 0 : 1
		);
	"'
	[ "$status" -eq 0 ]
}

@test "TZ cannot inject php.ini directives" {
	# A newline in TZ would otherwise append directives to the generated ini
	# file, and auto_prepend_file makes PHP parse an attacker-named file on
	# every request.
	TZ=$(printf 'UTC\nauto_prepend_file = /etc/hostname')
	export TZ
	export CONFIG_ENV="TZ"

	run generate_config 'cat /usr/local/etc/php/conf.d/timezone.ini'
	[ "$status" -eq 0 ]
	! printf '%s' "$output" | grep -q auto_prepend_file
}

@test "a legitimate TZ is still honoured" {
	export TZ="America/New_York"
	export CONFIG_ENV="TZ"

	run generate_config 'cat /usr/local/etc/php/conf.d/timezone.ini'
	[ "$status" -eq 0 ]
	[ "$output" = "date.timezone = America/New_York" ]
}
