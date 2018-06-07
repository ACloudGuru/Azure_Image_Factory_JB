### Create Resource Group
$name = 'shared-image-solution'
$location = 'South Central US'
$dateTime = $dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$tags = @( 
    "creationDate=$dateTime";
    "courseType=Maker Lab"; 
    "courseDescription=Azure Image Factory";
    "courseProvider=A Cloud Guru"
)
./scripts/createResourceGroup.ps1 -ResourceGroupName $name -ResourceGroupLocation $location -ResourceGroupTags $tags -Verbose

### Get Azure Key Vault
$name = 'acg-image-factory'
$resourceGroup = az group show --name $name | ConvertFrom-Json
$keyVaultName = 'image-factory-keyvault'
$vault = az keyvault show --name $keyVaultName --resource-group $resourceGroup.name | ConvertFrom-Json

### Get Template Files
$folderName = 'vm-shared'
$templateFolder = './arm/' + $folderName + '/'
$templateFile = $templateFolder + 'azureDeploy.json'
$templateParameters = $templateFolder + 'azureDeploy.parameters.json'

### Get latest Managed Image ID
$name = 'shared-image-gallery'
$resourceGroup = az group show --name $name | ConvertFrom-Json
$resources = az resource list --resource-group $resourceGroup.name | ConvertFrom-Json
$imageGallery = $resources | Where-Object {$_.type -eq 'Microsoft.Compute/galleries'} | Select-Object -First 1
$imageGalleryName = $imageGallery.name
$imageName = 'acg-ubuntu-image'
$imageVersions = $resources | Where-Object {$_.name -like "*$imageGalleryName/$imageName/*"}
$image = $imageVersions | Sort-Object -Property name -Descending | Select-Object -First 1

### Replace Shared Image ID in template parameters file
$parameters = Get-Content $templateParameters -Raw | ConvertFrom-Json
$parameters.parameters.adminPassword.reference.keyVault.id = $vault.id
$parameters.parameters.managedDiskId.value = $image.id
$parameters | ConvertTo-Json -Depth 100 | Out-File $templateParameters

### Deploy VM solution
$name = 'shared-image-solution'
$resourceGroup = az group show --name $name | ConvertFrom-Json
$dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$deploymentName = $resourceGroup.name + '-' + $dateTime
az group deployment create --resource-group $resourceGroup.name --template-file $templateFile --parameters @$templateParameters --name $deploymentName --verbose
