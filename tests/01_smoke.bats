#!/usr/bin/env bats
load helper.sh

@test "app serves the installation page with HTTP 200" {
	run curl -fsSL -o /dev/null -w '%{http_code}' "$(app_url /index.php/installation)"
	[ "$status" -eq 0 ]
	[ "$output" = "200" ]
}

@test "app root redirects into the app" {
	run curl -fsSL -o /dev/null -w '%{http_code}' "$(app_url /)"
	[ "$status" -eq 0 ]
	[ "$output" = "200" ]
}

@test "database accepts queries" {
	run dc exec -T mariadb mariadb -u easyappointments -peasyappointments easyappointments -e 'SELECT 1'
	[ "$status" -eq 0 ]
}

@test "app container connects to the database" {
	run dc exec -T easyappointments php -r 'mysqli_report(MYSQLI_REPORT_OFF); $c = @new mysqli(getenv("DB_HOST"), getenv("DB_USERNAME"), getenv("DB_PASSWORD"), getenv("DB_NAME")); exit($c->connect_errno ? 1 : 0);'
	[ "$status" -eq 0 ]
}
