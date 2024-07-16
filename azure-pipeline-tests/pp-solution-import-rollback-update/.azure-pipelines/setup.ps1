$PipelineConfig = . $PSScriptRoot/setup-config.ps1

. $PSScriptRoot/../../../azure-pipeline-scripts/pipeline-setup.ps1 -PipelineConfig $PipelineConfig
