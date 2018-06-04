### Create Resource Group
$name = 'acg-image-factory'
$location = 'Australia Southeast'
$dateTime = $dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$tags = @( 
    "creationDate=$dateTime";
    "courseType=Maker Lab"; 
    "courseDescription=Azure Image Factory";
    "courseProvider=A Cloud Guru"
)
./scripts/createResourceGroup.ps1 -ResourceGroupName $name -ResourceGroupLocation $location -ResourceGroupTags $tags -Verbose

### Deploy Azure Key Vault
$resourceGroup = az group show --name $name | ConvertFrom-Json
$keyVaultName = 'image-factory-keyvault'
$dateTime = $dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$tags = @( 
    "creationDate=$dateTime";
    "courseType=Maker Lab"; 
    "courseDescription=Azure Image Factory";
    "courseProvider=A Cloud Guru"
)
az keyvault create --resource-group $resourceGroup.name --name $keyVaultName --location $resourceGroup.location --enabled-for-template-deployment true --tags $tags --verbose
