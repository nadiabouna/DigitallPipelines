# No rollback patch update

Test the rollback of a patch solution that was imported as update and a rollback occurs

**Needed Resources:**

| Type               | Name                                            | Details                                                                         |
| ------------------ | ----------------------------------------------- | ------------------------------------------------------------------------------- |
| Pipeline           | (TEST CI) 00 No rollback patch update - prepare | [00-prepare-test-environment](.azure-pipelines/00-prepare-test-environment.yml) |
| Pipeline           | (TEST CI) 01 No rollback patch update - import  | [01-import-solutions](.azure-pipelines/01-import-solutions.yml)                 |
| Pipeline           | (TEST CI) 02 No rollback patch update - check   | [02-check-solutions](.azure-pipelines/02-check-solutions.yml)                   |
| Service Connection | (TEST CI) DIGITALL Pipelines Test               | GitHub service connection to DIGITALL Pipelines repo                            |
| Service Connection | (TEST CI) Test Solution Conn                    | Power Platform service connection to test environment                           |
| Environment        | (TEST CI) Test Solution Env                     | Target environment for solution deployment tests                                |
| Variable Group     | (TEST CI) Test Solution Url                     | Variable group containing environment url                                       |
| ...                | PowerPlatformUrl                                | Url to test environment                                                         |

## 00-prepare-test-environment.yml

1. Generate installed solutions
2. Delete solutions if already imported
3. Import base solution in version 1.0.0.0
4. Import patch solution in version 1.0.1.0

## 01-import-solutions.yml

1. Trigger: previous pipeline
2. Import upgrade solution `test_ci_pp_solution_import_rollback_update_Patch_1ed0b826` in version 1.0.2.0: expected success
3. Import solution `test_ci_pp_solution_import_rollback_update_fail`: expected failure
4. Rollback triggered: expected no uninstall
