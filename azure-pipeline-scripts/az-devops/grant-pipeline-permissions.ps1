<#
    Create new pipelines in azure devops
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$Organization,

    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$PipelineIds,

    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList]$PipelineResources
)

foreach ($resource in $PipelineResources) {
    Write-Debug "- Loading existing permissions for resource '$($resource.resourceId)' ($($resource.resourceType))"

    $pipelinePermissionsJson = az devops invoke `
        --area pipelinePermissions `
        --resource pipelinePermissions `
        --organization "$Organization" `
        --route-parameters `
        project="$ProjectName" `
        resourceType=$($resource.resourceType) `
        resourceId=$($resource.resourceId) `
        --http-method GET `
        --api-version=7.0-preview

    if ($LASTEXITCODE -ne 0) {
        throw "Error loading existing permissions for resource '$($resource.resourceId)' ($($resource.resourceType))"
    }

    $pipelinePermissions = $pipelinePermissionsJson | ConvertFrom-Json

    $updateNeeded = $false;
    foreach ($pipelineId in $PipelineIds) {

        $existingPermision = $pipelinePermissions.pipelines | Where-Object { $_.id -eq $pipelineId }

        if ($null -ne $existingPermision) {
            Write-Debug "> Permissions for pipeline '$($pipelineId)' already exist"
            continue
        }

        Write-Debug "> Permissions for pipeline '$($pipelineId)' are missing"
        $updateNeeded = $true;

        $pipelinePermissions.pipelines += @{
            authorized = $true;
            id         = $pipelineId;
        }
    }

    if (-Not $updateNeeded) {
        Write-Debug "- No permissions need to be updated"
        continue
    }

    $RandomFileName = "$(New-Guid).$($pipelineId).$($resource.resourceType).json"

    Write-Debug "- Writing to temp file '$($RandomFileName)'"
    $pipelinePermissions | ConvertTo-Json -Depth 3 | Out-File $RandomFileName

    Write-Debug "- Updating permissions for resource '$($resource.resourceId)' ($($resource.resourceType))"
    $null = az devops invoke `
        --area pipelinePermissions `
        --resource pipelinePermissions `
        --organization "$Organization" `
        --route-parameters `
        project="$ProjectName" `
        resourceType=$($resource.resourceType) `
        resourceId=$($resource.resourceId) `
        --http-method PATCH `
        --in-file $RandomFileName `
        --api-version=7.0-preview

    Write-Host "> Updated permissions for resource '$($resource.resourceId)' ($($resource.resourceType))"

    if ($LASTEXITCODE -ne 0) {
        throw "Error updating permissions for resource '$($resource.resourceId)' ($($resource.resourceType))"
    }

    Write-Debug "- Removing temp file '$($RandomFileName)'"
    Remove-Item $RandomFileName
}
