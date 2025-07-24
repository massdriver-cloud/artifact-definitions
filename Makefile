SHELL:=/bin/bash
TAG=release-$(shell date +%s)
MASS_BIN:=mass

.PHONY: local.server local.shutdown

dist:
	@if ! command -v $(MASS_BIN)  &> /dev/null; then echo "please install massdriver cli https://github.com/massdriver-cloud/mass" && exit 1; fi
	./hack/pack.rb
	@mkdir -p dist
	@rm -f .artifacts/*
	@$(foreach artifact,$(wildcard definitions/artifacts/*.json),$(MASS_BIN) schema dereference -f $(artifact) > dist/$(notdir $(basename $(artifact))).json;)
	@echo "Building dereferenced schemas to dist/"

local.server: local.update
	@if [ "$(shell docker ps -aq -f name=development-artifacts)" ]; then echo "Development server already running!"; else \
	docker run --rm -d --name development-artifacts -p 8081:80 -v $(shell pwd)/dist:/usr/share/nginx/html/artifact-definitions/massdriver nginx:1.23.1 &> /dev/null; \
	echo "Development server running! Set MASSDRIVER_URL=http://localhost:8081 to have the CLI pull artifact definitions from this server"; fi

local.shutdown:
	@if [ ! "$(shell docker ps -aq -f name=development-artifacts)" ]; then echo "Development server not running."; else \
	docker stop development-artifacts &> /dev/null; echo "Development server shutdown!"; fi


.PHONY: release
release:
	@if ! command -v gh  &> /dev/null; then echo "please install gh cli https://github.com/cli/cli#installation" && exit 1; fi
	@if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then echo "releasing is only supported from tip of origin/main currently: $(git rev-parse origin/main). Please git checkout main && git reset --hard origin/main and try again." && exit 1; fi
	gh release create ${TAG} --generate-notes --draft

clean:
	rm -rf dist/
