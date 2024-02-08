<#
    Tries to connect with an given subscription, account or tenant id (in that order)
    If none is provided an interactive login is started
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$AccountName,

    [Parameter(Mandatory = $false)]
    [string]$TenantId
)

if ($null -ne $SubscriptionId -and "" -ne $SubscriptionId) {
    Write-Debug "- Using subscription: $SubscriptionId"
    az account set --subscription $SubscriptionId

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to find account with subscription: $SubscriptionId"
    }

    az account show --output table
}
elseif ($null -ne $AccountName -and "" -ne $AccountName ) {
    Write-Debug "- Using accout: $AccountName"
    az account set --subscription $AccountName

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to find account with name: $AccountName"
    }

    az account show --output table
}
else {
    Write-Debug "- No subscription set. Starting interactive login"
    az login --tenant $TenantId --allow-no-subscriptions --output table

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to login"
    }
}