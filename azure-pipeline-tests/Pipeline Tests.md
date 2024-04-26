# Pipeline Tests

Some tests for testing pipeline templates and setup.

## Power Platform Solution Deployments

| Name                         | Description                                                                                           |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| Rollback first import        | Test the rollback of a solution that was imported and a rollback occurs                               |
| Rollback patch import        | Test the rollback of a solution patch that was imported and a rollback occurs                         |
| Rollback holding import      | Test the rollback of a solution upgrade if a rollback occurs after the holding solution was installed |
| No rollback patch update     | Test that patch is not affected if a rollback occurs after a patch is updated                         |
| No rollback solution upgrade | Test that solution is not affected if a rollback occurs after solution is upgraded                    |
