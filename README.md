# Flyway Hub Migration Test

This action is used in conjunction with [Flyway Hub](https://hub.flywaydb.org), a service for automated testing of [Flyway](https://flywaydb.org/) migration scripts.

Once your Flyway project is configured in Flyway Hub, the project migrations can be easily tested using this Action.

Migrations are tested by running them against an empty, ephemeral database instance, ensuring that your migrations are always in a clean state capable of creating a new database from scratch.

## Inputs

| Name            | Description                                                                           | Default          | Required |
| --------------- | ------------------------------------------------------------------------------------- | ---------------- | -------- |
| projectName     | The name of the Flyway Hub project to test                                            | N/A              | Yes      |
| engine          | The database engine that migrations should run against                                | N/A              | Yes      |
| flywayConfPath  | The path to the flyway conf to use when running this migration test                   | N/A              | No       |
| databaseName    | The custom database to create and run the flyway migrations against                   | N/A              | No       |
| migrationDirs   | The directories containing the migration scripts to run                               | N/A              | Yes      |

## Outputs

None.

## Example usage

```yaml
steps:
  - name: Test migrations on Flyway Hub
    uses: red-gate/flyway-hub-migration-test@v1
    with:
      projectName: myproject
      engine: PostgreSQL (v13.2)
      migrationDirs: sql
```

## Supported database engines

Valid arguments for the `engine` input are:

* SQL Server (v2017)
* SQL Server (v2019)
* PostgreSQL (v11.0)
* PostgreSQL (v12.0)
* PostgreSQL (v13.2)
* MySQL (v5.7)
* MySQL (v8.0)
* MariaDB (v10.6)

## Authentication

This action requires a Flyway Hub access token to access the Flyway Hub API.

This is expected to be provided to all actions through a `FLYWAY_HUB_ACCESS_TOKEN` environment variable. **This should be provided via a [GitHub Secret](https://docs.github.com/en/actions/reference/encrypted-secrets)**.
