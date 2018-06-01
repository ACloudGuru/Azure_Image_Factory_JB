[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [ValidateSet("Ubuntu","CentOS")]
    [string]$linuxOffer,
    [Parameter(Mandatory=$True)]
    [string]$imageResourceGroup
)

### Get latest image
$images = az image list --resource-group $imageResourceGroup | ConvertFrom-Json
$image = $images | Where-Object {$_.tags."image-offer" -like "*$linuxOffer*"} | Sort-Object -Property {$_.tags."image-build-timestamp"} -Descending | Select-Object -First 1
$imageId = $image.id

### Create VSTS variables
Write-Output ("##vso[task.setvariable variable=imageID;]$imageId")