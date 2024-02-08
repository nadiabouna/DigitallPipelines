<#
    Delete a service connection in Azure DevOps
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [PSCustomObject]$ServiceConnections
)

Write-Debug "- Loading existing service connections"

$serviceConnectionsJson = az devops service-endpoint list `
    --organization $Organization `
    --project "$ProjectName" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing service connections"
}

$serviceConnections = $serviceConnectionsJson | ConvertFrom-Json

Write-Debug "- Found $($serviceConnections.Count) existing service connections"

foreach ($serviceConnection in $ServiceConnections) {
    Write-Debug "- Checking if service connection '$($ServiceConnection.Name)' exists"

    $existingServiceConnection = $serviceConnections | Where-Object { $_.name -eq $ServiceConnection.Name }

    if ($null -ne $existingServiceConnection) {
        Write-Host "> Deleting service connection '$($ServiceConnection.Name)'"

        az devops service-endpoint delete `
            --id $existingServiceConnection.id `
            --organization $Organization `
            --project "$ProjectName" `
            --yes

        if ($LASTEXITCODE -ne 0) {
            throw "Error deleting service connection '$($ServiceConnection.Name)'"
        }

        Write-Debug "> Deleted service connection '$($ServiceConnection.Name)'"
    }
    else {
        Write-Debug "> Service connection '$($ServiceConnection.Name)' does not exist"
    }
}