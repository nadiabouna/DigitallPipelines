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
    [PSCustomObject]$PowerPlatformServiceConnections
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

foreach ($PowerPlatformServiceConnection in $PowerPlatformServiceConnections) {
    Write-Debug "- Checking if service connection '$($PowerPlatformServiceConnection.Name)' already exists"

    $existingServiceConnection = $serviceConnections | Where-Object { $_.name -eq $PowerPlatformServiceConnection.Name }

    if ($null -ne $existingServiceConnection) {
        Write-Debug "> Service connection '$($PowerPlatformServiceConnection.Name)' already exists"
        $result.Add(@{
                resourceType = "endpoint";
                resourceId   = $existingServiceConnection.id;
                new          = $false;
            }) > $null
        continue
    }

    Write-Debug "- Preparing service connection"

    $NewServiceConnection = @{
        name          = $PowerPlatformServiceConnection.Name;
        type          = "powerplatform-spn";
        url           = $PowerPlatformServiceConnection.Url;
        authorization = @{
            scheme     = "None";
            parameters = @{
                applicationId = $PowerPlatformServiceConnection.AppId;
                tenantId      = $PowerPlatformServiceConnection.TenantId;
                clientSecret  = $PowerPlatformServiceConnection.Secret;
            }
        }
    }
    $randomFileName = "$(New-Guid).powerplatform-spn.json"

    Write-Debug "- Creating temporary config file '$($randomFileName)'"

    $NewServiceConnection | ConvertTo-Json | Out-File $randomFileName

    Write-Host "> Creating service connection '$($PowerPlatformServiceConnection.Name)'"

    $env:AZURE_DEVOPS_EXT_GITHUB_PAT = $PowerPlatformServiceConnection.Pat

    $createdServiceConnectionJson = az devops service-endpoint create `
        --service-endpoint-configuration $randomFileName  `
        --organization $Organization `
        --project "$ProjectName" `
        --output json

    if ($LASTEXITCODE -ne 0) {
        throw "Error creating service connection '$($PowerPlatformServiceConnection.Name)'"
    }

    $createdServiceConnection = $createdServiceConnectionJson | ConvertFrom-Json

    $result.Add(@{
            resourceType = "endpoint";
            resourceId   = $createdServiceConnection.id;
            new          = $true;
        }) > $null

    Write-Debug "> Created service connection '$($createdServiceConnection.Name)'"

    Write-Debug "- Removing temporary config file '$($randomFileName)'"

    Remove-Item $randomFileName
}

return , $result