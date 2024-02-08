<#
    Create new pipelines in azure devops
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$Pipelines,

    [Parameter(Mandatory = $true)]
    [pscustomobject]$PipelineSource
)

Write-Debug "- Loading existing pipelines"
$Result = New-Object System.Collections.ArrayList

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
    Write-Debug "- Checking if pipeline '$($Pipeline.Name)' already exists"

    $existingPipeline = $existingPipelines | Where-Object { $_.name -eq $Pipeline.Name }

    if ($null -ne $existingPipeline) {
        Write-Debug "> Pipeline '$($Pipeline.Name)' already exists"
        $null = $Result.Add($existingPipeline.id)
    }
    else {
        Write-Host "> Creating Pipeline '$($Pipeline.Name)'"

        if ($PipelineSource.RepositoryType -eq "github") {
            Write-Debug "- Loading existing service connections"

            $serviceConnectionsJson = az devops service-endpoint list `
                --organization $Organization `
                --project "$ProjectName" `
                --output json

            if ($LASTEXITCODE -ne 0) {
                throw "Error loading existing service connections"
            }

            $serviceConnections = $serviceConnectionsJson | ConvertFrom-Json
            
            Write-Debug "> Found $($serviceConnections.Count) existing service connections"

            $existingServiceConnection = $serviceConnections | Where-Object { $_.name -eq $PipelineSource.RepositoryGitHubServiceConnectionName }

            if ($null -eq $existingServiceConnection) {
                Write-Error "> Service connection $PipelineSource.RepositoryGitHubServiceConnectionName does not exist"
                throw "Service connection $PipelineSource.RepositoryGitHubServiceConnectionName does not exist"
            }

            $newPipelinesJson = az pipelines create `
                --name $Pipeline.Name `
                --folder-path $Pipeline.PipelinePath `
                --skip-first-run `
                --repository-type $PipelineSource.RepositoryType `
                --repository $PipelineSource.RepositoryUrl `
                --service-connection $existingServiceConnection.id `
                --branch $PipelineSource.RepositoryBranch `
                --yml-path $Pipeline.Path `
                --organization $Organization `
                --project "$ProjectName" `
                --output json

            if ($LASTEXITCODE -ne 0) {
                throw "Error creating pipeline '$($Pipeline.Name)'"
            }
        }
        else {
            $newPipelinesJson = az pipelines create `
                --name $Pipeline.Name `
                --folder-path $Pipeline.PipelinePath `
                --skip-first-run `
                --repository-type $PipelineSource.RepositoryType `
                --repository $PipelineSource.RepositoryUrl `
                --branch $PipelineSource.RepositoryBranch `
                --yml-path $Pipeline.Path `
                --organization $Organization `
                --project "$ProjectName" `
                --output json

            if ($LASTEXITCODE -ne 0) {
                throw "Error creating pipeline '$($Pipeline.Name)'"
            }
        }

        $newPipeline = $newPipelinesJson | ConvertFrom-Json
        $null = $Result.Add($newPipeline.id)
    }
}

return , $Result