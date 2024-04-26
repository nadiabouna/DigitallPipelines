<#
    Delete existing pipelines in Azure DevOps
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$Pipelines
)

Write-Debug "- Loading existing pipelines"

$existingPipelinesJson = az pipelines list `
    --organization $Organization `
    --project "$ProjectName" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing pipelines"
}

$existingPipelines = $existingPipelinesJson | ConvertFrom-Json

Write-Debug "- Found $($existingPipelines.Count) existing pipelines"

foreach ($Pipeline in $Pipelines) {
    Write-Debug "- Checking if pipeline '$($Pipeline.Name)' exists"

    $existingPipeline = $existingPipelines | Where-Object { $_.name -eq $Pipeline.Name }

    if ($null -ne $existingPipeline) {
        Write-Host "> Deleting pipeline '$($Pipeline.Name)'"

        az pipelines delete `
            --id $existingPipeline.id `
            --organization $Organization `
            --project "$ProjectName" `
            --yes

        if ($LASTEXITCODE -ne 0) {
            throw "Error deleting pipeline '$($Pipeline.Name)'"
        }

        Write-Debug "> Deleted pipeline '$($Pipeline.Name)'"
    }
    else {
        Write-Debug "> Pipeline '$($Pipeline.Name)' does not exist"
    }
}