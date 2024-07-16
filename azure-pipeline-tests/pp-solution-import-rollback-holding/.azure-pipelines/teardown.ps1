[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$NoConfirmation
)

$PipelineConfig = . $PSScriptRoot/setup-config.ps1

. $PSScriptRoot/../../../azure-pipeline-scripts/pipeline-teardown.ps1 -PipelineConfig $PipelineConfig -NoConfirmation:$NoConfirmation
