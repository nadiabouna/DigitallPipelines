<#
    Create new environments in azure devops
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [hashtable[]]$Environments
)

Write-Debug "- Loading existing environments"

$existingEnvironmentsJson = az devops invoke `
    --area distributedtask `
    --resource environments `
    --route-parameters project="$ProjectName" `
    --organization $Organization `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing environments"
}

$existingEnvironments = ($ExistingEnvironmentsJson | ConvertFrom-Json).value

Write-Debug "- Found $($existingEnvironments.Count) existing environments"
$Result = New-Object System.Collections.ArrayList

foreach ($Environment in $Environments) {
    Write-Debug "- Checking if environment '$($Environment.Name)' already exists"

    $existingEnvironment = $existingEnvironments | Where-Object { $_.name -eq $Environment.Name }

    if ($null -ne $existingEnvironment) {
        Write-Debug "> Environment '$($Environment.Name)' already exists"
        $null = $Result.Add(@{
                resourceType = "environment";
                resourceId   = $existingEnvironment.id;
                new          = $false;
            })
    }
    else {
        Write-Debug "- Preparing environment request"
        $environment = @{
            name = $Environment.Name;
        }
        $RandomFileName = "$(New-Guid).environment.json"

        Write-Debug "- Creating temporary config file '$($RandomFileName)'"

        $environment | ConvertTo-Json | Out-File $RandomFileName

        Write-Host "> Creating environment '$($Environment.Name)'"
        $createdEnvironmentJson = az devops invoke `
            --area distributedtask `
            --resource environments `
            --route-parameters project="$ProjectName" `
            --http-method POST `
            --in-file $RandomFileName `
            --organization $Organization `
            --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Error creating environment '$($Environment.Name)'"
        }

        $existingEnvironment = $createdEnvironmentJson | ConvertFrom-Json

        Write-Debug "> Created environment '$($Environment.name)'"

        Write-Debug "- Removing temporary config file '$($RandomFileName)'"

        Remove-Item $RandomFileName

        $null = $Result.Add(@{
                resourceType = "environment";
                resourceId   = $existingEnvironment.id;
                new          = $true;
            })
    }
}

return , $Result