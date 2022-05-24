# Artifacts

Each bundle author is responsible for creating a artifact JSON Schema if their output artifacts are of a new type.

E.g.: If we don't have an AWS VPC type, the `aws-regional-cloud` author needs to create that type.

Artifact definitions should go through a peer review as they are a critical abstraction of MD.

Any `cloud` type should be composed of an ID type for that cloud. This type is used across all resources for a particular cloud (GCP, AWS, k8s, Azure).

E.g.: AWS VPC should be composed of an AWS ARN type.

Never `$ref` a remote type, always include them in this repo so changes are explicit and reviewable via PR. Futher `$ref`s are hydrated into the artifact definition and bundles when published as to not introduce side effects by remote refs being changed.

* ./artifact - artifact definitions for Massdriver
* ./specs - shared specifications for common capabilities provided by an artifact. E.g.: CloudSQL and RDS share the "RDBMS" spec.
  * Specs are also 'non-sensitive' information, thus can be used for filtering and searching in massdriver.
* ./types - simpler common types that can be reused by many artifacts. Types themselves are _not_ artifact definitions.

## Artifacts

Artifacts define connectable pieces of infrastructure in Massdriver. Artifacts that strictly represent infrastructure
_must_ have the format (omit fields if not applicable):

```js
{
  "data": {
    "infrastructure": { // REQUIRED
      "$ref": "../types/aws-infrastructure-eks.json"
    },
    "security": { // REQUIRED if applicable
      "policies": { // IAM policies this bundle created
        "read": "my_policy_foo",
        "write": "my_policy_foo2",
        "manage": "my_policy_foo3",
        "admin": "my_policy_foo4"
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
    },
    "observability": { // REQUIRED if applicable
      // Observability configuration this bundle created.
      "sqsAlertingToken": "foo"
    }
  },
  "specs": {
    // SPECS HERE
  }
}
```

Additionally, bundles that cross into the application plane and generate a credential _must_ include an `authentication` object. In this case an additional artifact _should_ be emitted in a cloud-agnostic manner if applicable.

Example:

AWS EKS generates a cluster admin credential for Kubernetes. Applications deploy to kubernetes, not EKS.

The AWS EKS bundle should emit _two_ artifacts: 

* `aws-eks-cluster` - This is used to connect infrastructure that _does not_ need k8s credentials
* `k8s-cluster` - This is used to connect applications that _do_ need credentials

The `k8s-cluster`'s data block should be _identical_ to the EKS's `data` block with the additional of an `authentication` field.

When creating these artifacts in terraform a local block should be used to eliminate typos between the two artifacts.

```js
{
  "data": {
    "infrastructure": { // REQUIRED
      "$ref": "../types/aws-infrastructure-eks.json"
    },
    "security": { // REQUIRED if applicable
      "policies": { // IAM policies this bundle created
        "read": "my_policy_foo",
        "write": "my_policy_foo2",
        "manage": "my_policy_foo3",
        "admin": "my_policy_foo4"
      },
      "groups": {
        // Security groups this bundle created
      },
    },
    "auditing": {
      // TBD:
    },
    "observability": { // REQUIRED if applicable
      // Observability configuration this bundle created.
      "sqsAlertingToken": "foo"
    }
    "authentication": { // REQUIRED if auth is created
      "token": "foo"
    }
  },
  "specs": {
    // SPECS HERE
  }
}
```

Artifacts _may_ only forward fields from previous artifacts if the field was immutable. This _must_ only be used if **necessary.**

* OK to forward example: AWS Massdriver Regional Cloud has a `region` field, bundles downstream from the MRC may forward the `region`
* NOT OK to forward example: AWS Pub/Sub fanout creates an IAM Policy document `foo`, downstream bundles may use `foo` but _must not_ forward it, as the policy's ARN _may_ change if the bundle were to switch which Pub/Sub subscription it is connected to.

## types

Types are a way to create composable infrastructure that is consistent across bundles.

* Types _must_ be scoped by their 'cloud' if cloud specific. e.g.: `aws-`, `gcp-`, `k8s-`
* Types that are not cloud specific, must _not_ be scoped. e.g.: `cidr`
* Types _may_ be scalar definitions designed for reuse of descriptions, validations, etc. e.g.: `cidr.json` defines CIDR ranges
* Types _must_ be sub-scoped if the represent a reusable `object` in artifacts. 
  * e.g.: `aws-infrastructure-` should be used for configurations placed under `data.infrastructure` in AWS artifacts
  * e.g.: `gcp-security-` should be used for configurations placed under `data.security` in GCP artifacts

## $md config

There is an top level `$md` field on some artifact definitions. These allow us to control how the front end treats them.

```json
{
  "$md": {
    "access": "private",
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
    "access": "public",
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

* access - specifies the access level of the artifact definition. `public` is readable by any Massdriver account, `private` is readable only by the organization that publishes the artifact definition. Defaults to `private` if unspecified.
* defaultTargetConnectionGroup - allows the artifacts of this type to be set as defaults for a Target, by omitting, it disables this artifact type as defaultable.
* defaultTargetConnectionGroupLabel - is the label to put on the section header for listing these types of artifacts
* importing.fileUploadType - allows files to be uploaded when importing an artifact. This requires that the artifact has the same structure as the file type. Generally only applicable to authentication
* importing.group - the group in onboarding and importing frontend that this artifact definition form should be grouped under.
* importing.fileUploadArtifactDataPath - the json key path to store the deserialized file into. Should be `["data"]` if not present.
