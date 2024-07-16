<#
    Tries to install azure cli and devops extension if not already installed
#>

Write-Debug "- Checking if Azure CLI is installed"

$azCli = Get-Command az -ErrorAction SilentlyContinue

if ($null -eq $azCli) {
    Write-Host "> Azure CLI is not installed. Installing..."

    if ($IsWindows) {
        Write-Host "Installing azure cli using winget..."
        winget install -e --id Microsoft.AzureCLI
    }

    if($IsMacOS){
        Write-Host "Installing azure cli using brew..."
        brew update && brew install azure-cli
    }

    if($IsLinux){
        Write-Host "Installing azure cli using installation script..."
        curl -L https://aka.ms/InstallAzureCli | bash
    }


    if ($LASTEXITCODE -ne 0) {
        throw "Failed to find install azure cli"
    }
}
else {
    Write-Debug "> Azure CLI is already installed"
}

az version --output table

Write-Debug "- Checking if Azure DevOps extension is installed"
$extension = az extension show --name azure-devops

if ($null -eq $extension) {
    Write-Host "> Azure DevOps extension is not installed. Installing..."
    az extension add --name azure-devops

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install devops extension"
    }
}
else {
    Write-Debug "> Azure DevOps extension is already installed"
}

az extension show --name azure-devops --output table