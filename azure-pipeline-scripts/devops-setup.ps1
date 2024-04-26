[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [pscustomobject]$DevOpsConfig
)

# Store current settings to be able to restore them later
$OldErrorPreference = $ErrorActionPreference
$OldDebugPreference = $DebugPreference

$ErrorActionPreference = "Stop"
# $DebugPreference = "Continue"

$PSStyle.Formatting.Debug = $PSStyle.Foreground.FromRgb(90, 99, 116)
$highlightColor = 'Blue'

try {
    Write-Host "---------- Install Azure CLI ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-cli/install.ps1

    Write-Host "---------- Connect with Azure Cli ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-cli/connect.ps1 `
        -SubscriptionId $DevOpsConfig.AzSubscriptionId `
        -AccountName $DevOpsConfig.AzAccountName `
        -TenantId $DevOpsConfig.AzTenantId

    Write-Host "---------- Create DevOps Project ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/new-project.ps1 `
        -Organization $DevOpsConfig.DevOpsOrganization `
        -ProjectName $DevOpsConfig.DevOpsProjectName `
        -ProjectDescription "Project created by Azure Pipeline"

    Write-Host "---------- Create Repositorys ----------" -ForegroundColor $highlightColor
    . $PSScriptRoot/az-devops/new-git-repositories.ps1 `
        -Organization $DevOpsConfig.DevOpsOrganization `
        -ProjectName $DevOpsConfig.DevOpsProjectName `
        -Repositories $DevOpsConfig.Repositories
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
