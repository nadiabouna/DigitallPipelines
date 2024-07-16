<#
    Create a service connection in azure devops
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [PSCustomObject]$GitHubServiceConnections
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
$result = [System.Collections.ArrayList]@()

foreach ($GitHubserviceConnection in $GitHubServiceConnections) {
    Write-Debug "- Checking if service connection '$($GitHubServiceConnection.Name)' already exists"

    $existingServiceConnection = $serviceConnections | Where-Object { $_.name -eq $GitHubServiceConnection.Name }

    if ($null -ne $existingServiceConnection) {
        Write-Debug "> Service connection '$($GitHubServiceConnection.Name)' already exists"
        $result.Add(@{
                resourceType = "endpoint";
                resourceId   = $existingServiceConnection.id;
                new          = $false;
            }) > $null
        continue
    }

    Write-Host "> Creating service connection '$($GitHubServiceConnection.Name)'"

    $env:AZURE_DEVOPS_EXT_GITHUB_PAT = $GitHubserviceConnection.Pat

    $createdServiceConnectionJson = az devops service-endpoint github create `
        --organization $Organization `
        --project "$ProjectName" `
        --github-url $gitHubServiceConnection.Url `
        --name $gitHubServiceConnection.Name `
        --output json

    if ($LASTEXITCODE -ne 0) {
        throw "Error creating service connection '$($GitHubServiceConnection.Name)'"
    }

    $createdServiceConnection = $createdServiceConnectionJson | ConvertFrom-Json

    $result.Add(@{
            resourceType = "endpoint";
            resourceId   = $createdServiceConnection.id;
            new          = $true;
        }) > $null

    Write-Debug "> Created service connection '$($createdServiceConnection.Name)'"
}

return , $result