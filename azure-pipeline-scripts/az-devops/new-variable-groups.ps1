<#
    Creates new variable groups with variables
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
$result = [System.Collections.ArrayList]@()

foreach ($VariableGroup in $VariableGroups) {
    Write-Debug "- Checking if variable group '$($variableGroup.Name)' already exists"

    $existingVariableGroup = $existingVariableGroups | Where-Object { $_.name -eq $VariableGroup.Name }

    if ($null -ne $existingVariableGroup) {
        Write-Debug "> Variable group '$($VariableGroup.Name)' already exists"
        $result.Add(@{
                resourceType = "variablegroup";
                resourceId   = $existingVariableGroup.id;
                new          = $false;
            }) > $null
    }
    else {
        Write-Debug "- Preparing variable group"
        $CreateVariables = ($VariableGroup.Variables
            | Where-Object { $_.Secret -eq $false }
            | ForEach-Object { "$($_.Name)=$($_.Value)" }
        ) -join ' '

        Write-Host "> Creating variable group '$($VariableGroup.Name)'"
        $createdVariableGroupJson = az pipelines variable-group create `
            --name $VariableGroup.Name `
            --organization $Organization `
            --project "$ProjectName" `
            --output json `
            --variables $CreateVariables

        if ($LASTEXITCODE -ne 0) {
            throw "Error creating variable group '$($VariableGroup.Name)'"
        }

        $existingVariableGroup = $createdVariableGroupJson | ConvertFrom-Json

        Write-Debug "> Created variable group '$($existingVariableGroup.name)'"
        $result.Add(@{
                resourceType = "variablegroup";
                resourceId   = $existingVariableGroup.id;
                new          = $true;
            }) > $null
    }

    Write-Debug "- Loading existing variables for variable group '$($VariableGroup.Name)'"

    $existingVariablesJson = az pipelines variable-group variable list `
        --group-id $existingVariableGroup.id `
        --organization $Organization `
        --project "$ProjectName" `
        --output json

    if ($LASTEXITCODE -ne 0) {
        throw "Error loading existing variables for variable group '$($VariableGroup.Name)'"
    }

    $existingVariables = $existingVariablesJson | ConvertFrom-Json

    Write-Debug "- Found $($existingVariables.Count) existing variables"

    foreach ($Variable in $VariableGroup.Variables) {
        Write-Debug "- Checking if variable '$($Variable.Name)' already exists"

        $existingVariable = $existingVariables.($Variable.Name)

        if ($null -ne $existingVariable) {
            Write-Debug "> Variable '$($Variable.Name)' already exists"
        }
        else {
            Write-Host "> Creating variable '$($Variable.Name)'"
            $createdVariableJson = az pipelines variable-group variable create `
                --group-id $existingVariableGroup.id `
                --name $Variable.Name `
                --value $Variable.Value `
                --secret $Variable.Secret `
                --organization $Organization `
                --project "$ProjectName" `
                --output json

            if ($LASTEXITCODE -ne 0) {
                throw "Error creating variable '$($Variable.Name)' in variable group '$($VariableGroup.Name)' (secret=$($Variable.Secret))"
            }

            $existingVariable = $createdVariableJson | ConvertFrom-Json
    
            Write-Debug "> Created variable '$($Variable.Name)'"
        }
    }
}

return , $result