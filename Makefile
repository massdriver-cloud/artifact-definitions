SHELL:=/bin/bash
TAG=release-$(shell date +%s)


.PHONY: release
release:
	  @if ! command -v gh  &> /dev/null; then echo "please install gh cli https://github.com/cli/cli#installation" && exit 1; fi
		@if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then echo "releasing is only supported from tip of origin/main currently: $(git rev-parse origin/main). Please git checkout main && git reset --hard origin/main and try again." && exit 1; fi
		gh release create ${TAG} --generate-notes --draft

validate:
	echo "TODO: make a build & validation script here and call it from pre-commit - I think we can do this with the pre-commit hook, no need to build first, its still json schema"
	echo "TODO: call mass definition get and compare for backwards compat"

	mass schema dereference ./definitions/artifacts/mysql-authentication.json > /tmp/schema.json && \
		mass schema validate -d /tmp/schema.json -s ./definitions/metaschema.json
