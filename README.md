# Massdriver Artifact Definitions

This repository contains the schema definitions that power Massdriver's Infrastructure as Code (IaC) artifact system. These schemas define the structure of **artifacts** (IaC outputs) and their metadata that can be used as **connections** between different IaC tools and workflows.

## Directory Structure

> ⚠️ **Important:** Use the compiled schemas in `dist/`, **not** the raw definitions in `definitions/`.
>
> The `definitions/` directory contains uncompiled source files used during schema development. These may include unresolved references and incomplete validations.
> For all SDKs, platform usage, IaC connections, and external integrations, **use the fully compiled schemas in the `dist/` directory**.


### `definitions/artifacts/`
**Complete, deployable resource definitions** that represent the outputs from IaC runs.

Artifacts are the **outputs** from IaC tools - think of IaC as a black box that takes inputs (params) and produces outputs (artifacts). These artifacts can then be used as **connections** to pipe data into other IaC tools' inputs.

Each artifact definition contains:
- **`data`** section: Encrypted, sensitive information (connection strings, passwords, ARNs, etc.) - not viewable in the platform
- **`specs`** section: Unencrypted, searchable metadata (hostnames, ports, versions, etc.) - accessible for discovery and filtering
- **UI metadata**: Icons, onboarding instructions, diagram orientation for the Massdriver platform

**Examples:**
- `aws-lambda-function.json` - Defines the output structure of a Lambda function deployment
- `postgresql-authentication.json` - Defines connection details for PostgreSQL databases across AWS RDS, Azure Flexible Server, GCP Cloud SQL
- `aws-iam-role.json` - Defines IAM role artifacts with trust policies and permissions

### `definitions/specs/`
**Common metadata schemas** that define shared properties across similar resource types.

Specs represent common characteristics between related resources. For example, all RDBMS systems (MySQL, PostgreSQL, RDS, Flexible Server) share common properties like hostnames, ports, engine versions, etc.

**Examples:**
- `rdbms.json` - Common database metadata (engine, version, engine_version)
- `aws.json` - AWS-specific metadata (region)
- `azure.json` - Azure-specific metadata (resource group, subscription)
- `gcp.json` - GCP-specific metadata (project, region)

### `definitions/types/`
**Primitive, reusable data type definitions** - the fundamental building blocks.

Types define basic data structures with validation rules that get composed into larger schemas. They represent cross-cutting concerns and reusable components.

**Examples:**
- `aws-arn.json` - ARN validation with regex patterns
- `port.json` - Port number validation (0-65535)
- `aws-security.json` - AWS security group and network configurations
- `azure-security.json` - Azure network security configurations

> **Note:** The type system is designed to promote code reuse and consistency, but keep references shallow (no more than 1-2 levels deep). This prevents over-engineering while still avoiding duplication of common patterns like port validation or ARN formatting.

## How It Works

### Artifact Composition
```
Types → Specs → Artifacts
```

1. **Types** provide basic building blocks (ARNs, ports, security configs)
2. **Specs** compose types into meaningful metadata schemas
3. **Artifacts** compose specs and types into complete, deployable resource definitions

### Connection Flow
```
IaC Tool A → Artifact Output → Connection → IaC Tool B Input
```

1. IaC Tool A produces an artifact (e.g., database deployment)
2. The artifact's `data` and `specs` become available as a connection
3. IaC Tool B can consume this connection as input params
4. The connection provides both encrypted data (connection strings) and searchable metadata (hostname, port)

### Data vs Specs in Connections

**Data (Encrypted):**
- Connection strings
- Passwords and secrets
- Private keys
- ARNs and resource identifiers
- Not viewable in the platform UI

**Specs (Unencrypted):**
- Hostnames and ports
- Version information
- Resource names and tags
- Searchable and filterable in the platform
- Used for resource discovery and dependency management

## Usage Examples

### Database Connection Example
```json
{
  "data": {
    "infrastructure": {
      "arn": "arn:aws:rds:us-west-2:123456789012:db:my-database"
    },
    "authentication": {
      "username": "admin",
      "password": "encrypted-password",
      "hostname": "my-database.cluster-xyz.us-west-2.rds.amazonaws.com",
      "port": 5432
    }
  },
  "specs": {
    "rdbms": {
      "engine": "postgresql",
      "version": "13.7",
      "engine_version": "13.7"
    },
    "aws": {
      "region": "us-west-2"
    }
  }
}
```

In this example:
- The `data` section contains the encrypted connection details
- The `specs` section contains searchable metadata about the database type and location
- Another IaC tool can connect to this database using the connection, accessing both the encrypted credentials and the public metadata

### Cross-Cloud Compatibility
Many artifacts support multiple cloud providers. For example, `postgresql-authentication.json` can represent:
- AWS RDS PostgreSQL
- Azure Database for PostgreSQL Flexible Server
- GCP Cloud SQL PostgreSQL
- Kubernetes PostgreSQL deployments

The same artifact structure works across all providers, with cloud-specific infrastructure references in the `data.infrastructure` section.

## Development

### Adding New Artifacts
1. Create a new JSON schema in `definitions/artifacts/`
2. Define the `data` and `specs` sections
3. Reference existing types and specs where possible
4. Add UI metadata for the Massdriver platform
5. Include instructions for importing the artifact

### Adding New Specs
1. Create a new JSON schema in `definitions/specs/`
2. Define common properties for a category of resources
3. Reference existing types for validation
4. Provide examples and descriptions

### Adding New Types
1. Create a new JSON schema in `definitions/types/`
2. Define validation rules (patterns, ranges, etc.)
3. Include examples and error messages
4. Make it reusable across multiple artifacts and specs

## Contributing

When contributing new definitions:
- Follow the existing schema patterns
- Use descriptive titles and descriptions
- Include examples where helpful
- Reference existing types and specs to maintain consistency
- Consider cross-cloud compatibility where applicable
