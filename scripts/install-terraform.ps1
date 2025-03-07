# Set Variables
$TerraformVersion = "1.8.0"
$InstallPath = "C:\dev"
$TerraformZip = "$InstallPath\terraform.zip"
$TerraformExe = "$InstallPath\terraform.exe"
$TerraformURL = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"

# Create the installation directory if it doesn't exist
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath | Out-Null
}

# Download Terraform
Write-Host "Downloading Terraform v$TerraformVersion..."
Invoke-WebRequest -Uri $TerraformURL -OutFile $TerraformZip

# Extract Terraform binary
Write-Host "Extracting Terraform..."
Expand-Archive -Path $TerraformZip -DestinationPath $InstallPath -Force

# Remove the zip file after extraction
Remove-Item -Path $TerraformZip -Force

# Verify Installation
if (Test-Path $TerraformExe) {
    Write-Host "Terraform installed successfully at $TerraformExe"
} else {
    Write-Host "Terraform installation failed!"
}

# Add to PATH (Optional)
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
if ($CurrentPath -notlike "*$InstallPath*") {
    Write-Host "Adding Terraform to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$InstallPath", [System.EnvironmentVariableTarget]::Machine)
}

# Display Terraform Version
& $TerraformExe -version