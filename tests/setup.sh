#!/bin/sh

set -e

. "$(dirname -- "$0")/helper.sh"

make -C "$PROJECT_ROOT" build
dc up -d --wait
