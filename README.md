# easyappointments-docker

A Docker image for [Easy!Appointments](https://easyappointments.org), the open
source appointment scheduler.

The image bundles Easy!Appointments 1.6.0 on PHP 8.4 (Apache) and configures
itself from environment variables, so the same image works in compose,
Kubernetes, or plain `docker run`.

The `config.php` written at container start is a fixed file that reads those
variables at runtime; no value is ever substituted into it. That keeps
environment content out of the PHP parser entirely — a password containing a
quote is just a password — and means the generated file holds no secrets.

## Quick start

```sh
make build   # build the image with buildx bake
make up      # start the app + mariadb via compose
```

Then open http://localhost:8888 and follow the installation wizard.

Copy `.env.example` to `.env` (done automatically on first `make` run) to
override the port, base URL, or database password.

## Environment variables

| Variable             | Default                 |
| -------------------- | ----------------------- |
| BASE_URL             | `http://localhost`      |
| LANGUAGE             | `english`               |
| DEBUG_MODE           | `false`                 |
| DB_HOST              | `mariadb`               |
| DB_NAME              | `easyappointments`      |
| DB_USERNAME          | `easyappointments`      |
| DB_PASSWORD          | `easyappointments`      |
| GOOGLE_SYNC_FEATURE  | `false`                 |
| GOOGLE_CLIENT_ID     |                         |
| GOOGLE_CLIENT_SECRET |                         |
| TZ                   | `UTC`                   |

`DEBUG` is accepted as a legacy alias for `DEBUG_MODE`. `TZ` must be a plain
zone identifier (`America/New_York`, `Etc/GMT+5`, `UTC`); anything else is
rejected with a warning and `UTC` is used, because that value is written into
a `php.ini` fragment.

## Make targets

| Target        | Description                                        |
| ------------- | -------------------------------------------------- |
| `build`       | Build the image via `docker buildx bake`           |
| `up` / `up-d` | Start the stack (foreground / detached)            |
| `down`        | Stop the stack and remove volumes                  |
| `logs`        | Tail the stack logs                                |
| `ps`          | Show stack status                                  |
| `test/e2e`    | Run the bats smoke test suite                      |
| `format`      | Format shell scripts with shfmt                    |
| `lint`        | Check shell script formatting                      |
| `prepare`     | Install the toolchain (asdf, bats, shfmt, cloc)    |
| `clean`       | Remove generated Make state                        |
| `purge`       | `clean` + remove everything not tracked by git     |

## Publishing

Images are tagged `${DOCKER_REGISTRY}/easyappointments` with `latest`, the git
commit, and the Easy!Appointments version. `DOCKER_REGISTRY` defaults to
`registry.gitlab.com/bitspur/rock8s/easyappointments-docker`.

Multi-arch (linux/amd64 + linux/arm64) publishing:

```sh
make build BAKE_OUTPUT=registry
```

Local builds produce a single image for the host architecture (works on both
amd64 and arm64/Apple Silicon hosts — the base images are multi-arch).

## Upgrading Easy!Appointments

Bump `EASYAPPOINTMENTS_VERSION` in `make.mk` and rebuild. Existing
installations must run the database migrations after upgrading — see the
[upstream update guide](https://easyappointments.org/docs.html).

## Tests

```sh
make test/e2e
```

Builds the image, brings the stack up with a throwaway database, and asserts
the app serves HTTP 200 and can reach the database. A second file covers
`config.php` generation, including that hostile environment values stay data:
the generated file is byte-identical whatever the environment holds. Set
`KEEP_STACK=1` to leave the stack running after the suite for inspection.

## License

[MIT License](LICENSE)
