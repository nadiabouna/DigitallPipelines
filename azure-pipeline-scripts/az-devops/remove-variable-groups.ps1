<#
    Deletes existing variable groups
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [PSCustomObject]$VariableGroups
)

Write-Debug "- Loading existing variable groups"

$existingVariableGroupsJson = az pipelines variable-group list `
    --organization $Organization `
    --project "$ProjectName" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing variable groups"
}

$existingVariableGroups = $existingVariableGroupsJson | ConvertFrom-Json

Write-Debug "- Found $($existingVariableGroups.Count) existing variable groups"

foreach ($VariableGroup in $VariableGroups) {
    Write-Debug "- Checking if variable group '$($VariableGroup.Name)' exists"

    $existingVariableGroup = $existingVariableGroups | Where-Object { $_.name -eq $VariableGroup.Name }

    if ($null -ne $existingVariableGroup) {
        Write-Host "> Deleting variable group '$($VariableGroup.Name)'"

        az pipelines variable-group delete `
            --group-id $existingVariableGroup.id `
            --organization $Organization `
            --project "$ProjectName" `
            --yes

        if ($LASTEXITCODE -ne 0) {
            throw "Error deleting variable group '$($VariableGroup.Name)'"
        }

        Write-Debug "> Deleted variable group '$($VariableGroup.Name)'"
    }
    else {
        Write-Debug "> Variable group '$($VariableGroup.Name)' does not exist"
    }
}