[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [pscustomobject]$PipelineConfig
)

# Store current settings to be able to restore them later
$OldErrorPreference = $ErrorActionPreference
$OldDebugPreference = $DebugPreference

$ErrorActionPreference = "Stop"
# $DebugPreference = "Continue"

$PSStyle.Formatting.Debug = $PSStyle.Foreground.FromRgb(90, 99, 116)
$highlightColor = 'Blue'

try {
    $PipelineResources = [System.Collections.ArrayList]@()
    $PipelineIds = [System.Collections.ArrayList]@()

    Write-Host "---------- Install Azure CLI ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-cli/install.ps1

    Write-Host "---------- Connect with Azure Cli ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-cli/connect.ps1 `
        -SubscriptionId $PipelineConfig.AzSubscriptionId `
        -AccountName $PipelineConfig.AzAccountName `
        -TenantId $PipelineConfig.AzTenantId

    Write-Host "---------- Create GitHub Service Connections ----------" -ForegroundColor $highlightColor
    $GitHubServiceConnections = . $PSScriptRoot/az-devops/new-github-service-connection.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -GitHubServiceConnections $PipelineConfig.GitHubServiceConnections

    if ($null -ne $GitHubServiceConnections) {
        Write-Debug "Marking $($GitHubServiceConnections.Count) service connections to share with pipelines"
        $PipelineResources.AddRange($GitHubServiceConnections)
    }

    Write-Host "---------- Create Power Platform Service Connections ----------" -ForegroundColor $highlightColor
    $PowerPlatformServiceConnections = . $PSScriptRoot/az-devops/new-power-platform-service-connection.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -PowerPlatformServiceConnections $PipelineConfig.PowerPlatformServiceConnections

    if ($null -ne $PowerPlatformServiceConnections) {
        Write-Debug "Marking $($PowerPlatformServiceConnections.Count) service connections to share with pipelines"
        $PipelineResources.AddRange($PowerPlatformServiceConnections)
    }

    Write-Host "---------- Create Variable Groups ----------" -ForegroundColor $highlightColor
    $VariableGroups = . $PSScriptRoot/az-devops/new-variable-groups.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -VariableGroups $PipelineConfig.VariableGroups


    if ($null -ne $VariableGroups) {
        Write-Debug "Marking $($VariableGroups.Count) variable groups to share with pipelines"
        $PipelineResources.AddRange($VariableGroups)
    }

    Write-Host "---------- Create Environments ----------" -ForegroundColor $highlightColor
    $Environments = . $PSScriptRoot/az-devops/new-environments.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -Environments $PipelineConfig.Environments

    if ($null -ne $Environments) {
        Write-Debug "Marking $($Environments.Count) environments to share with pipelines"
        $PipelineResources.AddRange($Environments)
    }

    Write-Host "---------- Create Pipelines ----------" -ForegroundColor $highlightColor
    $Pipelines = . $PSScriptRoot/az-devops/new-pipelines.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -Pipelines $PipelineConfig.Pipelines `
        -PipelineSource $PipelineConfig.PipelineSource

    if ($null -ne $Pipelines) {
        Write-Debug "Marking $($Pipelines.Count) pipelines to share resources with"
        $PipelineIds.AddRange($Pipelines)
    }

    Write-Host "---------- Grant pipeline permissions ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/grant-pipeline-permissions.ps1 `
        -Organization $PipelineConfig.DevOpsOrganization `
        -ProjectName $PipelineConfig.DevOpsProjectName `
        -PipelineResources $PipelineResources `
        -PipelineIds $PipelineIds
}
catch {
    Write-Host "Error: $_"
    exit 1
}
finally {
    # Restore previous preferences
    $ErrorActionPreference = $OldErrorPreference
    $DebugPreference = $OldDebugPreference
}
