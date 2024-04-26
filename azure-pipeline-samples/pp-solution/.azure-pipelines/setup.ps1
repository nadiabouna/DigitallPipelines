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
            Url      = $ENV:PP_CONN_DEV_URL;
            AppId    = $ENV:PP_CONN_DEV_APPID;
            TenantId = $ENV:PP_CONN_DEV_TENANTID;
            Name     = "Power Platform Service Connection Development";
            Secret   = $ENV:PP_CONN_DEV_SECRET;
        },
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
            Name      = "Power Platform Environment Development";
            Variables = @(
                @{
                    Name   = "PowerPlatformUrl";
                    Value  = $ENV:PP_CONN_DEV_URL;
                    Secret = $false;
                }
            )
        },
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
            Name = "Power Platform Environment Development";
        },
        @{
            Name = "Power Platform Environment Test";
        },
        @{
            Name = "Power Platform Environment Prod";
        },
        @{
            Name = "Power Platform Environment Development Solution Concept";
        }
    );

    Pipelines                       = @(
        @{
            Name         = "Upgrade solution concept";
            Path         = "/.azure-pipelines/dgt-solution-concept/upgrade-solution-concept.yml";
            PipelinePath = "solutions/solution-concept"
        },
        @{
            Name         = "Update solution configuration";
            Path         = "/.azure-pipelines/solutions/update-solution-configuration.yml";
            PipelinePath = "solutions"
        },
        @{
            Name         = "Export solutions";
            Path         = "/.azure-pipelines/solutions/export-solution.yml";
            PipelinePath = "solutions"
        },
        @{
            Name         = "Deploy solutions";
            Path         = "/.azure-pipelines/solutions/deploy-solution.yml";
            PipelinePath = "solutions"
        }
    );

    PipelineSource                  = @{
        RepositoryType   = "tfsgit";
        RepositoryUrl    = "$ENV:DEVOPS_ORGANIZATION/$ENV:DEVOPS_PROJECT_NAME/_git/Solutions";
        RepositoryBranch = "main";
    };
}

. $PSScriptRoot/../../../azure-pipeline-scripts/pipeline-setup.ps1 -PipelineConfig $PipelineConfig