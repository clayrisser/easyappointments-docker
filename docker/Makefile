.POSIX:
ROOTDIR ?= $(eval ROOTDIR := $(shell git rev-parse --show-toplevel))$(ROOTDIR)
include $(ROOTDIR)/make.mk

.DEFAULT_GOAL := bake

export BAKE_OUTPUT ?= docker
BAKE_ARGS ?= -f $(ROOTDIR)/docker/docker-bake.hcl --pull --provenance=false --allow=fs.read=..
ifeq (registry,$(BAKE_OUTPUT))
BAKE_ARGS += --set '*.platform=linux/amd64,linux/arm64' --push
else
BAKE_ARGS += --load
endif

.PHONY: bake bake/%
bake: $(ROOTDIR)/.dockerignore
	@[ "$(BAKE_OUTPUT)" != registry ] || case "$(GIT_COMMIT)" in *-dirty) echo "refusing to push from dirty tree (GIT_COMMIT=$(GIT_COMMIT)) — commit first" >&2; exit 1;; esac
	@$(BUILDX) bake $(BAKE_ARGS)
bake/%: $(ROOTDIR)/.dockerignore
	@[ "$(BAKE_OUTPUT)" != registry ] || case "$(GIT_COMMIT)" in *-dirty) echo "refusing to push from dirty tree (GIT_COMMIT=$(GIT_COMMIT)) — commit first" >&2; exit 1;; esac
	@$(BUILDX) bake $(BAKE_ARGS) $*

$(ROOTDIR)/.dockerignore: $(ROOTDIR)/.gitignore
	@cp "$<" "$@"

.PHONY: up up-d down logs ps
up:
	@$(COMPOSE) -f $(ROOTDIR)/docker/compose.yaml up
up-d:
	@$(COMPOSE) -f $(ROOTDIR)/docker/compose.yaml up -d --wait
down:
	@$(COMPOSE) -f $(ROOTDIR)/docker/compose.yaml down --volumes --remove-orphans
logs:
	@$(COMPOSE) -f $(ROOTDIR)/docker/compose.yaml logs -f
ps:
	@$(COMPOSE) -f $(ROOTDIR)/docker/compose.yaml ps
