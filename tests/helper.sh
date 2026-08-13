# Shared helpers for the bats e2e suite. POSIX sh.
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${BATS_TEST_DIRNAME:-${BATS_SUITE_DIRNAME:-$(dirname -- "$0")}}/.." && pwd)}"
COMPOSE_FILE="$PROJECT_ROOT/docker/compose.yaml"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-easyappointments-test}"
EASYAPPOINTMENTS_PORT="${EASYAPPOINTMENTS_PORT:-8888}"
export COMPOSE_PROJECT_NAME EASYAPPOINTMENTS_PORT

# Same image reference compose.yaml resolves, so tests can exercise the image
# directly without needing the stack up.
DOCKER_REGISTRY="${DOCKER_REGISTRY:-registry.gitlab.com/bitspur/rock8s/easyappointments-docker}"
DOCKER_TAG="${DOCKER_TAG:-latest}"
APP_IMAGE="$DOCKER_REGISTRY/easyappointments:$DOCKER_TAG"
export DOCKER_REGISTRY DOCKER_TAG APP_IMAGE

dc() {
	docker compose -f "$COMPOSE_FILE" --project-name "$COMPOSE_PROJECT_NAME" "$@"
}

app_url() {
	echo "http://localhost:$EASYAPPOINTMENTS_PORT$1"
}

# Runs the image's entrypoint in a throwaway container so that it generates
# config.php, then evaluates $1 (a sh snippet) against what it wrote. Exits 97
# if generation itself failed, so a broken entrypoint cannot masquerade as a
# passing assertion.
#
# Variables named in CONFIG_ENV are handed to `docker run --env NAME`, which
# copies them from the caller's environment by name. Nothing interpolates the
# values, so passwords containing quotes, spaces or newlines arrive intact.
generate_config() {
	_args=""
	for _var in ${CONFIG_ENV:-DB_PASSWORD}; do
		_args="$_args --env $_var"
	done
	# shellcheck disable=SC2086
	docker run --rm $_args --entrypoint /bin/sh "$APP_IMAGE" -c \
		"docker-entrypoint.sh true >/dev/null 2>&1 || exit 97; $1"
}
