### Create Resource Group
$name = 'shared-image-gallery'
$location = 'West Central US'
$dateTime = $dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$tags = @( 
    "creationDate=$dateTime";
    "courseType=Maker Lab"; 
    "courseDescription=Azure Image Factory";
    "courseProvider=A Cloud Guru"
)
./scripts/createResourceGroup.ps1 -ResourceGroupName $name -ResourceGroupLocation $location -ResourceGroupTags $tags -Verbose
$resourceGroup = az group show --name $name | ConvertFrom-Json

### Get Template Files
$folderName = 'sig-gallery'
$templateFolder = './arm/' + $folderName + '/'
$templateFile = $templateFolder + 'azureDeploy.json'
$templateParameters = $templateFolder + 'azureDeploy.parameters.json'

### Deploy Shared Image Gallery
$dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$deploymentName = $resourceGroup.name + '-' + $dateTime
az group deployment create --resource-group $resourceGroup.name --template-file $templateFile --parameters @$templateParameters --name $deploymentName --verbose
