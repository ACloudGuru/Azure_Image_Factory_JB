### Get Azure Key Vault
$name = 'acg-image-factory'
$keyVaultName = 'image-factory-keyvault'
$vault = az keyvault show --name $keyVaultName --resource-group $name | ConvertFrom-Json

### Get VSTS Project Service Principal
$accountName = 'acloudgurulabs'
$projectName = 'Image Factory'
$servicePrincipals = az ad sp list | ConvertFrom-Json
$servicePrincipal = $servicePrincipals | Where-Object {$_.displayname -like "*$accountName-$projectName*"}

### Authorise Service Principal in Key Vault
az keyvault set-policy --name $vault.name --resource-group $vault.resourceGroup --object-id $servicePrincipal.objectId --spn $servicePrincipal.appDisplayName --secret-permissions get list