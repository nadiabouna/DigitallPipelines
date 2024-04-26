return @{
    AzSubscriptionId                = $ENV:AZURE_CLI_SUBSCRIPTTION_ID;
    AzAccountName                   = $ENV:AZURE_CLI_ACCOUNT_NAME;
    AzTenantId                      = $ENV:AZURE_CLI_TENANT_ID;

    DevOpsTenantId                  = $ENV:DEVOPS_TENANT_ID;
    DevOpsOrganization              = $ENV:DEVOPS_ORGANIZATION;
    DevOpsProjectName               = $ENV:DEVOPS_PROJECT_NAME;

    GitHubServiceConnections        = @(
        @{
            Name = "(TEST CI) DIGITALL Pipelines Test";
            Url  = "https://github.com/DIGITALLNature/DIGITALLPipelines";
            Pat  = $ENV:GITHUB_PAT;
        }
    );

    PowerPlatformServiceConnections = @(
        @{
            Url      = $ENV:PP_CONN_TEST_URL;
            AppId    = $ENV:PP_CONN_TEST_APPID;
            TenantId = $ENV:PP_CONN_TEST_TENANTID;
            Name     = "(TEST CI) Test Solution Conn";
            Secret   = $ENV:PP_CONN_TEST_SECRET;
        }
    );

    VariableGroups                  = @(
        @{
            Name      = "(TEST CI) Test Solution Url";
            Variables = @(
                @{
                    Name   = "PowerPlatformUrl";
                    Value  = $ENV:PP_CONN_TEST_URL;
                    Secret = $false;
                }
            )
        }
    );

    Environments                    = @(
        @{
            Name = "(TEST CI) Test Solution Env";
        }
    );

    Pipelines                       = @(
        @{
            Name         = "(TEST CI) 00 No rollback solution upgrade - prepare";
            Path         = "/azure-pipeline-tests/pp-solution-import-rollback-upgrade/.azure-pipelines/00-prepare-test-environment.yml";
            PipelinePath = "pipeline-tests/pp-solution-import-rollback-upgrade"
        },
        @{
            Name         = "(TEST CI) 01 No rollback solution upgrade - import";
            Path         = "/azure-pipeline-tests/pp-solution-import-rollback-upgrade/.azure-pipelines/01-import-solutions.yml";
            PipelinePath = "pipeline-tests/pp-solution-import-rollback-upgrade"
        },
        @{
            Name         = "(TEST CI) 02 No rollback solution upgrade - check";
            Path         = "/azure-pipeline-tests/pp-solution-import-rollback-upgrade/.azure-pipelines/02-check-solutions.yml";
            PipelinePath = "pipeline-tests/pp-solution-import-rollback-upgrade"
        }
    );

    PipelineSource                  = @{
        RepositoryType                        = "github";
        RepositoryUrl                         = "https://github.com/DIGITALLNature/DIGITALLPipelines";
        RepositoryBranch                      = "main";
        RepositoryGitHubServiceConnectionName = "(TEST CI) DIGITALL Pipelines Test";
    };
}