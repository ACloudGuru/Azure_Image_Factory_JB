### Get Resource Group
$name = 'acg-image-factory'
$resourceGroup = az group show --name $name | ConvertFrom-Json

### Get Azure Key Vault
$keyVaultName = 'image-factory-keyvault'
$vault = az keyvault show --name $keyVaultName --resource-group $resourceGroup.name | ConvertFrom-Json

### Store new password in KeyVault
$password = (1..$(Get-Random -Minimum 12 -Maximum 16) | ForEach-Object {([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126))) | Get-Random}) -join “”
$secretName = 'vmadmin-password'
az keyvault secret set --vault-name $vault.name --name $secretName --value $password --description 'Password for vmadmin user on Linux VMs' --verbose

### Get Template Files
$folderName = 'vm'
$templateFolder = './arm/' + $folderName + '/'
$templateFile = $templateFolder + 'azureDeploy.json'
$templateParameters = $templateFolder + 'azureDeploy.parameters.json'

### Get latest Managed Image ID
$imageOffer = 'UbuntuServer'
$imageSku = '16.04-LTS'
$images = (az image list | ConvertFrom-Json) | Where-Object {$_.tags.'image-offer' -eq $imageOffer}
$image = $images | Sort-Object -Property tags.'image-build-timestamp' | Select-Object -First 1

### Replace Key Vault ID in template parameters file
$parameters = Get-Content $templateParameters -Raw | ConvertFrom-Json
$parameters.parameters.adminPassword.reference.keyVault.id = $vault.id
$parameters.parameters.managedDiskId.value = $image.id
$parameters | ConvertTo-Json -Depth 100 | Out-File $templateParameters

### Deploy VM solution
$dateTime = Get-Date -UFormat +%Y%m%d-%H%M%S
$deploymentName = $resourceGroup.name + '-' + $dateTime
az group deployment create --resource-group $resourceGroup.name --template-file $templateFile --parameters @$templateParameters --name $deploymentName --verbose
