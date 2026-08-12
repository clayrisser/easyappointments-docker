# Shared helpers for the bats e2e suite. POSIX sh.
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${BATS_TEST_DIRNAME:-${BATS_SUITE_DIRNAME:-$(dirname -- "$0")}}/.." && pwd)}"
COMPOSE_FILE="$PROJECT_ROOT/docker/compose.yaml"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-easyappointments-test}"
EASYAPPOINTMENTS_PORT="${EASYAPPOINTMENTS_PORT:-8888}"
export COMPOSE_PROJECT_NAME EASYAPPOINTMENTS_PORT

dc() {
	docker compose -f "$COMPOSE_FILE" --project-name "$COMPOSE_PROJECT_NAME" "$@"
}

app_url() {
	echo "http://localhost:$EASYAPPOINTMENTS_PORT$1"
}
