### Get Azure Key Vault
$name = 'acg-image-factory'
$keyVaultName = 'image-factory-keyvault'
$vault = az keyvault show --name $keyVaultName --resource-group $name | ConvertFrom-Json

### Create Subscription Account ID secret
$secretName = 'packer-account-id'
$secretValue = (az account show | ConvertFrom-Json).id
$secretDescription = 'Azure subscription for Packer to build in'
az keyvault secret set --vault-name $vault.name --name $secretName --value $secretValue --description $secretDescription

### Create Service Principal for Packer
$sp = az ad sp create-for-rbac --name 'packer-builder' | ConvertFrom-Json

### Create Packer Account ID secret
$secretName = 'packer-client-id'
$secretValue = $sp.appId
$secretDescription = 'Service Principal ID for the Packer Builder'
az keyvault secret set --vault-name $vault.name --name $secretName --value $secretValue --description $secretDescription

### Create Packer Account password secret
$secretName = 'packer-client-secret'
$secretValue = $sp.password
$secretDescription = 'Service Principal password for the Packer Builder'
az keyvault secret set --vault-name $vault.name --name $secretName --value $secretValue --description $secretDescription

### Create Packer SSH secret
$secretName = 'packer-client-secret'
$secretValue = (1..$(Get-Random -Minimum 12 -Maximum 16) | ForEach-Object {([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126))) | Get-Random}) -join “”
$secretDescription = 'SSH password for the Packer Builder'
az keyvault secret set --vault-name $vault.name --name $secretName --value $secretValue --description $secretDescription
