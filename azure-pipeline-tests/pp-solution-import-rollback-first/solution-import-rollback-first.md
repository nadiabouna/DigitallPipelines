# Rollback first import

Test the rollback of a solution that was imported and a rollback occurs

**Needed Resources:**

| Type               | Name                                         | Details                                                                         |
| ------------------ | -------------------------------------------- | ------------------------------------------------------------------------------- |
| Pipeline           | (TEST CI) 00 Rollback first import - prepare | [00-prepare-test-environment](.azure-pipelines/00-prepare-test-environment.yml) |
| Pipeline           | (TEST CI) 01 Rollback first import - import  | [01-import-solutions](.azure-pipelines/01-import-solutions.yml)                 |
| Pipeline           | (TEST CI) 02 Rollback first import - check   | [02-check-solutions](.azure-pipelines/02-check-solutions.yml)                   |
| Service Connection | (TEST CI) DIGITALL Pipelines Test            | GitHub service connection to DIGITALL Pipelines repo                            |
| Service Connection | (TEST CI) Test Solution Conn                 | Power Platform service connection to test environment                           |
| Environment        | (TEST CI) Test Solution Env                  | Target environment for solution deployment tests                                |
| Variable Group     | (TEST CI) Test Solution Url                  | Variable group containing environment url                                       |
| ...                | PowerPlatformUrl                             | Url to test environment                                                         |

## 00-prepare-test-environment.yml

1. Generate installed solutions
2. Delete any solutions that are installed (using reverse list in `solution-configuration.yml`)

## 01-import-solutions.yml

1. Trigger: Previous pipeline
2. Import Solution `test_ci_pp_solution_import_rollback_first_empty`: Expected success
3. Import Solution `test_ci_pp_solution_import_rollback_first_fail`: Expected failure
4. Rollback Triggered: Expected uninstall of `test_ci_pp_solution_import_rollback_first_empty`
