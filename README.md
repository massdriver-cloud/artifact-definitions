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

Our JSON Schema metaschema for artifact definitions can be found [here](https://api.massdriver.cloud/json-schemas/artifact-definition.json).

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

**Note:** We will be moving our artifact definitions to our OCI registry in the near future which will alleviate the need for 'packing' markdown and icons into the artifact definition JSON.

Our JSON Schema metaschema for artifact definitions can be found [here](https://api.massdriver.cloud/json-schemas/artifact-definition.json).

There is an top level `$md` field on some artifact definitions. These allow us to control how the front end treats them.

Based on the JSON schema, here's a markdown document describing the `$md` configuration options:

### $md Configuration Options

The `$md` object contains configuration metadata for Massdriver artifact definitions. All artifact definitions must include this section.


- **`name`** (string): The type name of the artifact definition. Must be unique to your organization and will be prefixed with your organization's slug. Must match pattern `^[a-z0-9-]{3,100}$`. This will be used by your bundles to refer to the types that they depend on or emit.

- **`label`** (string): The display label shown in the Massdriver UI.

- **`icon`** (string): Path to an icon file for this artifact type. Must be a valid URL.

- **`ui`** (object): UI-specific configuration options.
  - **`environmentDefaultGroup`** (string): Adds this artifact definition type to the 'environment default' overlay under this group in the UI.
  - **`connectionOrientation`** (string): How to orient the artifact's connection to a bundle in the UI. Options:
    - `"link"` (default): Line-based connections
    - `"environmentDefault"`: Makes it the default for a given type in the entire environment
  - **`instructions`** (array): Onboarding instructions for this artifact type. Only valid for 'credentials' artifact definitions. Each instruction object contains:
    - `label` (string): The instruction label
    - `content` (string): The instruction content

- **`export`** (array): Export format configurations for downloading artifact data.
  - **`templateLang`** (string, required): Template language. Currently only supports `"liquid"`
  - **`fileFormat`** (string, required): File format. Currently only supports `"yaml"`
  - **`template`** (string, required): Base64 encoded template for the export file
  - **`downloadButtonText`** (string, required): Text displayed on the download button in the UI

**Example:*

```json
{
  "$md": {
    "name": "aws-iam-role",
    "label": "AWS IAM Role",
    "icon": "https://example.com/icons/iamn.svg",
    "ui": {
      "environmentDefaultGroup": "credentials",
      "connectionOrientation": "environmentDefault",
      "instructions": [
        {
          "label": "Creating a role with the CLI",
          "content": "BASE64_MARKDOWN_HERE"
        },
        {
          "label": "Creating a role in the AWS Web Console",
          "content": "BASE64_MARKDOWN_HERE"
        }
      ]
    },
    "export": [
      {
        "templateLang": "liquid",
        "fileFormat": "yaml",
        "template": "base64EncodedTemplateHere",
        "downloadButtonText": "Title for downloadable version of artifact here"
      }
    ]
  }
}
```
