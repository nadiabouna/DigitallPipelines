$PipelineConfig = . $PSScriptRoot/setup-config.ps1

. $PSScriptRoot/../../../azure-pipeline-scripts/az-devops/invoke-pipeline `
    -Organization $PipelineConfig.DevOpsOrganization `
    -Project $PipelineConfig.DevOpsProjectName `
    -PipelineName "(TEST CI) 00 Rollback first import - prepare"
