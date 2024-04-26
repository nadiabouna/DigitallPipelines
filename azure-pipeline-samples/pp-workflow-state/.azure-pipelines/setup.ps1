$PipelineConfig = @{
    AzSubscriptionId                = $ENV:AZURE_CLI_SUBSCRIPTTION_ID;
    AzAccountName                   = $ENV:AZURE_CLI_ACCOUNT_NAME;
    AzTenantId                      = $ENV:AZURE_CLI_TENANT_ID;

    DevOpsTenantId                  = $ENV:DEVOPS_TENANT_ID;
    DevOpsOrganization              = $ENV:DEVOPS_ORGANIZATION;
    DevOpsProjectName               = $ENV:DEVOPS_PROJECT_NAME;

    GitHubServiceConnections        = @(
        @{
            Name = "DIGITALL Pipelines Service Connection";
            Url  = "https://github.com/DIGITALLNature/DIGITALLPipelines";
            Pat  = $ENV:GITHUB_PAT;
        }
    );

    PowerPlatformServiceConnections = @(
        @{
            Url      = $ENV:PP_CONN_TEST_URL;
            AppId    = $ENV:PP_CONN_TEST_APPID;
            TenantId = $ENV:PP_CONN_TEST_TENANTID;
            Name     = "Power Platform Service Connection Test";
            Secret   = $ENV:PP_CONN_TEST_SECRET;
        },
        @{
            Url      = $ENV:PP_CONN_PROD_URL;
            AppId    = $ENV:PP_CONN_PROD_APPID;
            TenantId = $ENV:PP_CONN_PROD_TENANTID;
            Name     = "Power Platform Service Connection Prod";
            Secret   = $ENV:PP_CONN_PROD_SECRET;
        }
    );

    VariableGroups                  = @(
        @{
            Name      = "Power Platform Environment Test";
            Variables = @(
                @{
                    Name   = "PowerPlatformUrl";
                    Value  = $ENV:PP_CONN_TEST_URL;
                    Secret = $false;
                }
            )
        },
        @{
            Name      = "Power Platform Environment Prod";
            Variables = @(
                @{
                    Name   = "PowerPlatformUrl";
                    Value  = $ENV:PP_CONN_PROD_URL;
                    Secret = $false;
                }
            )
        }
    );

    Environments                    = @(
        @{
            Name = "Power Platform Environment Test";
        },
        @{
            Name = "Power Platform Environment Prod";
        }
    );

    Pipelines                       = @(
        @{
            Name         = "Set workflow states (manual)";
            Path         = "/.azure-pipelines/workflows/set-workflow-state.yml";
            PipelinePath = "workflows"
        }
    );

    PipelineSource                  = @{
        RepositoryType   = "tfsgit";
        RepositoryUrl    = "$ENV:DEVOPS_ORGANIZATION/$ENV:DEVOPS_PROJECT_NAME/_git/Solutions";
        RepositoryBranch = "main";
    };
}

. $PSScriptRoot/../../../azure-pipeline-scripts/pipeline-setup.ps1 -PipelineConfig $PipelineConfig
