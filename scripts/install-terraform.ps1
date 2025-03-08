$TerraformVersion = '1.8.0'
$InstallPath = 'C:\dev'

$TerraformZip = $InstallPath + '\terraform.zip'
$TerraformExe = $InstallPath + '\terraform.exe'
$TerraformURL = 'https://releases.hashicorp.com/terraform/' + $TerraformVersion + '/terraform_' + $TerraformVersion + '_windows_386.zip'

curl $TerraformURL --output $TerraformZip
Expand-Archive -Path $TerraformZip -DestinationPath $InstallPath -Force
Remove-Item -Path $TerraformZip -Force
& $TerraformExe -version || exit 1

$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\dev'
