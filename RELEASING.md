# Releasing Massdriver Artifact Definitions
## Branch Convention
Only create new releases from tip of `origin/main`.

## Naming Convention
We name releases `release-${unix-timestamp-seconds}`.

## From CLI
Make sure to install the [`gh` CLI](https://github.com/cli/cli#installation).

Use the convenience make target to generate the canonical release tag and generate the release notes for you:
```bash
make release
```
This will create a draft release and print a browser link to it for you to review in GH UI before manually confirming.
This gives you the opportunity as a release author to add any additional comments to the changelog / release notes.
