# Flyway Hub Migration Test

This action is used in conjunction with [Flyway Hub](https://hub.flywaydb.org), a service for automated testing of [Flyway](https://flywaydb.org/) migration scripts.

Once your Flyway project is configured in Flyway Hub, the project migrations can be easily tested using this Action.

Migrations are tested by running them against an empty, ephemeral database instance, ensuring that your migrations are always in a clean state capable of creating a new database from scratch.

## Inputs

| Name            | Description                                                                           | Default          | Required |
| --------------- | ------------------------------------------------------------------------------------- | ---------------- | -------- |
| projectId       | The id of the project number to test                                                  | N/A              | Yes      |

## Outputs

None.

## Example usage

```yaml
steps:
  - name: Test migrations on Flyway Hub
    uses: red-gate/flyway-hub-migration-test@v1
    with:
      projectId: 1
```

## Authentication

This action requires a Flyway Hub access token to access the Flyway Hub API.

This is expected to be provided to all actions through a `FLYWAY_HUB_ACCESS_TOKEN` environment variable. **This should be provided via a [GitHub Secret](https://docs.github.com/en/actions/reference/encrypted-secrets)**.
