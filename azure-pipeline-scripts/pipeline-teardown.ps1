[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [pscustomobject]$PipelineConfig,

    [Parameter()]
    [switch]$NoConfirmation
)

# Store current settings to be able to restore them later
$OldErrorPreference = $ErrorActionPreference
$OldDebugPreference = $DebugPreference

$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

$PSStyle.Formatting.Debug = $PSStyle.Foreground.FromRgb(90, 99, 116)
$highlightColor = 'Red'

Write-Warning "You are about to delete potentially needed resources. Please ensure you have backups or have confirmed that these resources are no longer needed."

if (-not $NoConfirmation) {
    $confirmation = Read-Host "Are you sure you want to delete these resources? (yes/no)"
    if ($confirmation -ne 'yes') {
        Write-Host "Aborted by user." -ForegroundColor Red
        return
    }
}

try {
    Write-Host "---------- Delete Service Connections ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/remove-service-connection.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -ServiceConnections ($PipelineConfig.GitHubServiceConnections + $PipelineConfig.PowerPlatformServiceConnections)

    Write-Host "---------- Delete Variable Groups ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/remove-variable-groups.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -VariableGroups $PipelineConfig.VariableGroups

    Write-Host "---------- Delete Environments ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/remove-environments.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -Environments $PipelineConfig.Environments

    Write-Host "---------- Delete Pipelines ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/remove-pipelines.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -Pipelines $PipelineConfig.Pipelines
}
finally {
    # Restore original settings
    $ErrorActionPreference = $OldErrorPreference
    $DebugPreference = $OldDebugPreference
}