param(
  [Parameter(Mandatory=$True)]
  [string]
  $SubscriptionId,

  [Parameter(Mandatory=$True)]
  [string]
  $ResourceGroupName,

  [string]
  $ResourceGroupLocation = "West Europe",

  [string]
  $AppServiceName,

  [ValidateScript({Test-Path $_ -PathType Leaf})]
  [string]
  $TemplateFilePath = "$PSScriptRoot\..\Azure\azuredeploy.json"
)

$ErrorActionPreference = "Stop"

if (-not (Get-AzureRmContext)) {
  # sign in
  Write-Host "Logging in..."
  Login-AzureRmAccount
}

# select subscription
Write-Host "Selecting subscription '$SubscriptionId'"
Select-AzureRmSubscription -SubscriptionID $SubscriptionId

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
  Write-Host "Resource group '$ResourceGroupName' does not exist. To create a new resource group, please enter a location."
  if(-not $ResourceGroupLocation) {
      $ResourceGroupLocation = Read-Host "resourceGroupLocation"
  }
  Write-Host "Creating resource group '$ResourceGroupName' in location '$ResourceGroupLocation'"
  New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
}

$TemplateParameters = @{
  subscriptionId = $SubscriptionId;
  location = $ResourceGroupLocation;
  serverFarmResourceGroup = $ResourceGroupName;
  hostingPlanName = "solr";
  appServiceName = $AppServiceName;
}

# Start the deployment
Write-Host "Starting deployment..."
New-AzureRmResourceGroupDeployment `
  -ResourceGroupName $ResourceGroupName `
  -TemplateFile $TemplateFilePath `
  @TemplateParameters
