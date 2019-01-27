param(
  [string]
  $ResourceGroupName,

  [string]
  $AppServiceName,

  [string]
  $ResourceGroupLocation = "West Europe",

  [string]
  $SolrZipUrl = "http://archive.apache.org/dist/lucene/solr/6.6.3/solr-6.6.3.zip"
)

$ZipPath = [IO.Path]::ChangeExtension((Join-Path $env:temp ([IO.Path]::GetFileName($SolrZipUrl))), "custom.zip")

if (-not (Test-Path $ZipPath)) {
  Write-Host "Downloading '$SolrZipUrl' to '$ZipPath'..."
  Invoke-WebRequest -Uri $SolrZipUrl -OutFile $ZipPath
}

Write-Host "Copying wwwroot into '$ZipPath'..."
Compress-Archive -Path "$PSScriptRoot\..\wwwroot\*" -Update -DestinationPath $ZipPath

[xml] $PublishingProfileXml = Get-AzureRmWebAppPublishingProfile `
  -ResourceGroupName $ResourceGroupName `
  -Name $AppServiceName

$KudoPublishProfile = $PublishingProfileXml.publishData.publishProfile | ? { $_.publishMethod -eq "MSDeploy" }

Write-Host "Starting Kudo publish..."
$Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $KudoPublishProfile.userName, $KudoPublishProfile.userPWD)))
Invoke-RestMethod `
  -Uri "https://$($KudoPublishProfile.publishUrl)/api/zipdeploy" `
  -Headers @{Authorization=("Basic {0}" -f $Base64AuthInfo)} `
  -Method POST `
  -InFile $ZipPath `
  -ContentType "multipart/form-data"

Write-Host "Publish of '$ZipPath' to '$($KudoPublishProfile.destinationAppUrl)' completed."
