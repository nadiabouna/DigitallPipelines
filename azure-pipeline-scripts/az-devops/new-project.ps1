<#
    Create new team project in azure devops
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter()]
    [string]$ProjectDescription,

    [Parameter()]
    [string]$Process = "Agile",

    [Parameter()]
    [string]$Visibility = "private"
)

Write-Debug "- Loading existing team projects"

$existingProjectsJson = az devops project list `
    --organization "$Organization" `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Error loading existing team projects"
}

$existingProjects = $existingProjectsJson | ConvertFrom-Json

Write-Debug "- Found $($existingProjects.value.Count) existing team projects"

Write-Debug "- Checking if team project '$($ProjectName)' already exists"

$existing = $existingProjects.value | Where-Object { $_.name -eq $ProjectName }

if ($null -ne $existing) {
    Write-Host "> Environment '$($ProjectName)' already exists"
    return $existing.id
}
else {
    Write-Host "> Creating Team Project '$($ProjectName)'"

    $newProjectJson = az devops project create `
        --name "$ProjectName" `
        --organization "$Organization" `
        --description "$ProjectDescription" `
        --process $Process `
        --visibility $Visibility `
        --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Error creating team project '$($ProjectName)'"
        }

        $newProject = $newProjectJson | ConvertFrom-Json
        return $newProject.id
}