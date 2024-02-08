<#
    Delete existing environments in Azure DevOps
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

foreach ($Environment in $Environments) {
    Write-Debug "- Checking if environment '$($Environment.Name)' exists"

    $existingEnvironment = $existingEnvironments | Where-Object { $_.name -eq $Environment.Name }

    if ($null -ne $existingEnvironment) {
        Write-Host "> Deleting environment '$($Environment.Name)'"

        az devops invoke `
            --area distributedtask `
            --resource environments `
            --route-parameters project="$ProjectName" environmentId="$($existingEnvironment.id)" `
            --http-method DELETE `
            --organization $Organization `
            --output table

        if ($LASTEXITCODE -ne 0) {
            throw "Error deleting environment '$($Environment.Name)'"
        }

        Write-Debug "> Deleted environment '$($Environment.Name)'"
    }
    else {
        Write-Debug "> Environment '$($Environment.Name)' does not exist"
    }
}