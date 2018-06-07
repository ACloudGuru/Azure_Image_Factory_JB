### Get Resource Group
$name = 'shared-image-gallery'
$resourceGroup = az group show --name $name | ConvertFrom-Json

### Get Template Files
$folderName = 'sig-image'
$templateFolder = './arm/' + $folderName + '/'
$templateFile = $templateFolder + 'azureDeploy.json'
$templateParameters = $templateFolder + 'azureDeploy.parameters.json'

### Deploy Shared Image Gallery Image
$dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$deploymentName = $resourceGroup.name + '-' + $dateTime
az group deployment create --resource-group $resourceGroup.name --template-file $templateFile --parameters @$templateParameters --name $deploymentName --verbose
