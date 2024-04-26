<#
    Create new repositories in azure devops
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$Repositories
)

Write-Debug "- Loading existing repositories"
$Result = New-Object System.Collections.ArrayList

$existingRepositoriesJson = az repos list `
    --organization "$Organization" `
    --project "$ProjectName" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing team repositories"
}

$existingRepositories = $existingRepositoriesJson | ConvertFrom-Json

Write-Debug "- Found $($existingPipelines.Count) existing repositories"

foreach ($Repository in $Repositories) {
    Write-Debug "- Checking if respository '$($Repository.Name)' already exists"

    $existingRepository = $existingRepositories | Where-Object { $_.name -eq $Repository.Name }

    if ($null -ne $existingRepository) {
        Write-Debug "> Repository '$($Repository.Name)' already exists"
        $null = $Result.Add($Repository.id)
    }
    else {
        Write-Host "> Creating Repository '$($Repository.Name)'"
        $newRepositoryJson = az repos create `
        --name $Repository.Name `
        --organization "$Organization" `
        --project "$ProjectName" `
        --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Error creating repository '$($Repository.Name)'"
        }

        if($null -ne $Repository.Template) {
            Write-Host "> Initalize Repository from '$($Repository.Template)'"
            az repos import create `
            --git-source-url $Repository.Template `
            --repository $Repository.Name `
            --organization "$Organization" `
            --project "$ProjectName" `
            --output json

            if ($LASTEXITCODE -ne 0) {
                throw "Error initializing repository '$($Repository.Name)'"
            }
        }

        $newRepository = $newRepositoryJson | ConvertFrom-Json
        $null = $Result.Add($newRepository.id)
    }
}

return , $Result