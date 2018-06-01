### Define URI
$repo = 'hashicorp/packer'
$uri = "https://api.github.com/repos/$repo/tags"

### Get latest version from repo tags
$tags = (Invoke-WebRequest -Uri $uri | ConvertFrom-Json)
$latestVersion = $tags[0].name.Replace('v','')

### Create VSTS variables
Write-Output ("##vso[task.setvariable variable=packerVersion;]$latestVersion")