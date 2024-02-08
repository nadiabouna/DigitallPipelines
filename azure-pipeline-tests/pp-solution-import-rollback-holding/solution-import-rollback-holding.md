# Rollback holding import

Test the rollback of a solution that was imported as a holding and a rollback occurs

**Needed Resources:**

| Type               | Name                                           | Details                                                                         |
| ------------------ | ---------------------------------------------- | ------------------------------------------------------------------------------- |
| Pipeline           | (TEST CI) 00 Rollback holding import - prepare | [00-prepare-test-environment](.azure-pipelines/00-prepare-test-environment.yml) |
| Pipeline           | (TEST CI) 01 Rollback holding import - import  | [01-import-solutions](.azure-pipelines/01-import-solutions.yml)                 |
| Pipeline           | (TEST CI) 02 Rollback holding import - check   | [02-check-solutions](.azure-pipelines/02-check-solutions.yml)                   |
| Service Connection | (TEST CI) DIGITALL Pipelines Test              | GitHub service connection to DIGITALL Pipelines repo                            |
| Service Connection | (TEST CI) Test Solution Conn                   | Power Platform service connection to test environment                           |
| Environment        | (TEST CI) Test Solution Env                    | Target environment for solution deployment tests                                |
| Variable Group     | (TEST CI) Test Solution Url                    | Variable group containing environment url                                       |
| ...                | PowerPlatformUrl                               | Url to test environment                                                         |

## 00-prepare-test-environment.yml

1. Generate installed solutions
2. Delete solutions if already imported
3. Import solution in version 1.0.0.0

## 01-import-solutions.yml

1. Trigger: previous pipeline
2. Import upgrade solution `test_ci_pp_solution_import_rollback_holding` in version 2.0.0.0: expected success
3. Import solution `test_ci_pp_solution_import_rollback_holding_fail`: expected failure
4. Rollback triggered:
    - expected uninstall of `test_ci_pp_solution_import_rollback_holding_Upgrade`
    - expected solution `test_ci_pp_solution_import_rollback_holding` to be installed in version 1.0.0.0
