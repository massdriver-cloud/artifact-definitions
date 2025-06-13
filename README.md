# Massdriver Core Artifact Definitions

This repo contains [Massdriver's](https://massdriver.cloud) core artifact definitions for emitting state between IaC tools. All of these types are available in platform, or for forking / cloning and customizing under your org. Learn more about [artifact definitions here](https://docs.massdriver.cloud/concepts/artifact-definitions).

Each bundle author is responsible for creating a artifact JSON Schema if their output artifacts are of a new type.

E.g.: If we don't have an AWS VPC type, the `aws-vpc` author needs to create that type.

Artifact definitions should go through a peer review as they are a critical abstraction of MD.

Any `cloud` type should be composed of an ID type for that cloud. This type is used across all resources for a particular cloud (GCP, AWS, k8s, Azure).

E.g.: AWS VPC should be composed of an AWS ARN type.

Never `$ref` a remote type, always include them in this repo so changes are explicit and reviewable via PR. Futher `$ref`s are hydrated into the artifact definition and bundles when published as to not introduce side effects by remote refs being changed.

* ./artifact - artifact definitions for Massdriver
* ./specs - shared specifications for common capabilities provided by an artifact. E.g.: CloudSQL and RDS share the "RDBMS" spec.
  * Specs are also 'non-sensitive' information, thus can be used for filtering and searching in massdriver.
* ./types - simpler common types that can be reused by many artifacts. Types themselves are _not_ artifact definitions.

## Development
Install the pre-commit to ensure our json is pretty and our json schemas valid in tighter development cycles.
```bash
pre-commit install
```

## Artifacts

Artifacts define connectable pieces of infrastructure in Massdriver. Artifacts that strictly represent infrastructure
_must_ have the format top-level `data` and `specs` keys, underneath you can define any schema that makes sense for standardizing
connectivity between IaC modules.

`data` attributes in massdriver are considered secret and are stored encrypted-at-rest and in flight. `specs` are visible attributes about the resource that can be displayed in the UI.

All attributes are accessible by downstream IaC modules 'connected' to the output of an upstream IaC module.

Our JSON Schema metaschema for artifact definitions can be found [here](./artifact-definition-metaschema.json).

```js
{
  "data": {
    "infrastructure": { // REQUIRED
      "$ref": "../types/aws-infrastructure-eks.json"
    },
    "security": { // REQUIRED if applicable
      "policies": { // IAM policies this bundle created
        "read": "my_policy_foo",
        "write": "my_policy_foo2"
      },
      "groups": {
        // Security groups this bundle created, downstream bundles will attach and set up their own security group rules.
        // AWS Example
        // service named => {arn, service port, service protocol}
        "postgresql": {
          "arn": "arn:securitygroup:foo"
          "port": 5432,
          "protocol": "tcp"
        }
      },
    },
    "auditing": {
      // TBD:
    }
  },
  "specs": {
    // SPECS HERE
  }
}
```


## types

`./types` are shared internal to this repo JSON Schemas used for common concepts. They are not a Massdriver concept, so much as a means of making configuration of the core-types more DRY.

## $md config

There is an top level `$md` field on some artifact definitions. These allow us to control how the front end treats them.

```json
{
  "$md": {
    "defaultTargetConnectionGroup": "credentials",
    "defaultTargetConnectionGroupLabel": "GCP Service Account",
    "importing": {
      "fileUploadType": "json",
      "fileUploadArtifactDataPath": ["data"],
      "group": "authentication"
    }
  }
}
```

```json
{
  "$md": {
    "name": "the-artifact-name",
    "defaultTargetConnectionGroup": "credentials",
    "defaultTargetConnectionGroupLabel": "Kubernetes",
    "importing": {
      "fileUploadType": "yaml",
      "fileUploadArtifactDataPath": ["data", "authentication"],
      "group": "authentication"
    }
  }
}
```

* name - the name of the artifact without the organizational scope. This should be a URL safe name consisting of letters, numbers, and hyphens. It must be unique to the org it is published under.
* _deprecated_: defaultTargetConnectionGroup - allows the artifacts of this type to be set as defaults for a Target, by omitting, it disables this artifact type as defaultable.
* _deprecated_: defaultTargetConnectionGroupLabel - is the label to put on the section header for listing these types of artifacts
* _deprecated_: importing.fileUploadType - allows files to be uploaded when importing an artifact. This requires that the artifact has the same structure as the file type. Generally only applicable to authentication
* _deprecated_: importing.group - the group in onboarding and importing frontend that this artifact definition form should be grouped under.
* _deprecated_: importing.fileUploadArtifactDataPath - the json key path to store the deserialized file into. Should be `["data"]` if not present.
* `export` - different file formats of the artifact that can be downloaded
  * `downloadButtonText` - download button text
  * `templateLang` - the template to render the artifact in (currently only liquid is supported)
  * `fileFormat` - the file extension to use when rendering
  * `template` - the template
* `ui.instructions` - onboarding instructions for this artifact type, only valid for 'credentials' artifact definitions.
* `ui.environmentDefaultGroup` - adds this artifact definition type to the 'environment default' overlay under this group in the UI.
* `ui.connectionOrientation` - how to orient the artifact's connection to a bundle in the UI. `link` will be line based, `environmentDefault` will make it the default for a given type in the entire environment.
* `extensions.costReporting` - setting this field to true will enable cost reporting with this artifact (currently not supported in self-hosted).
