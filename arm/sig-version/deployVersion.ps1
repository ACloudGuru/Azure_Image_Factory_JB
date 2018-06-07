### Get Resource Group
$name = 'shared-image-gallery'
$resourceGroup = az group show --name $name | ConvertFrom-Json

### Get Template Files
$folderName = 'sig-version'
$templateFolder = './arm/' + $folderName + '/'
$templateFile = $templateFolder + 'azureDeploy.json'
$templateParameters = $templateFolder + 'azureDeploy.parameters.json'

### Get latest Managed Image ID
$imageOffer = 'UbuntuServer'
$imageSku = '16.04-LTS'
$images = (az image list | ConvertFrom-Json) | Where-Object {$_.tags.'image-offer' -eq $imageOffer -and $_.tags.'image-sku' -eq $imageSku}
$image = $images | Sort-Object -Property tags.'image-build-timestamp' | Select-Object -First 1

### Replace Key Vault ID in template parameters file
$parameters = Get-Content $templateParameters -Raw | ConvertFrom-Json
$parameters.parameters.versionProperties.value.publishingProfile.source.managedImage.id = $image.id
$parameters | ConvertTo-Json -Depth 100 | Out-File $templateParameters

### Deploy Shared Image Gallery Image Version
$dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$deploymentName = $resourceGroup.name + '-' + $dateTime
az group deployment create --resource-group $resourceGroup.name --template-file $templateFile --parameters @$templateParameters --name $deploymentName --verbose
