[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $Package,

    [Parameter()]
    [string] $Version,

    [Parameter()]
    [string] $Switches,
  
    [Parameter()]
    [string] $IgnoreChecksums,

    [Parameter()]
    [string] $Url,

    [Parameter()]
    [string] $BypassProxy
)

if (-not $Package) {
    throw "Package parameter is mandatory. Please provide a value for the Package parameter."
}

###################################################################################################
#
# PowerShell configurations
#

# Ensure we force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Expected path of the choco.exe file.
$Choco = "$Env:ProgramData/chocolatey/choco.exe"

###################################################################################################
#
# Functions used in this script.
#

function Ensure-Chocolatey
{
    [CmdletBinding()]
    param(
        [string] $ChocoExePath
    )

    if (-not (Test-Path "$ChocoExePath"))
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        $installScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
        Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -OutFile $installScriptPath

        try {
            Execute -File $installScriptPath
        } finally {
            Remove-Item $installScriptPath
        }
        
        if ($LastExitCode -eq 3010)
        {
            Write-Host 'The recent changes indicate a reboot is necessary. Please reboot at your earliest convenience.'
        }
    }
}

function Install-Package
{
    [CmdletBinding()]
    param(
        [string] $ChocoExePath,
        [string] $Package,
        [string] $Version,
        [string] $Switches,        
        [string] $IgnoreChecksums,
        [string] $Url
    )

    $expression = "$ChocoExePath install $Package"
    
    if ($Version){
        $expression = "$expression --version $Version"
    }

    if ($Switches){
        $expression = "$expression --params ""'$Switches'"" "
    }

    $expression = "$expression -y -f --acceptlicense --no-progress --stoponfirstfailure"
    
    if ($IgnoreChecksums -eq "true") {
        $expression = "$expression --ignorechecksums"
    }

    $packageLocationPath = [System.IO.Path]::GetTempPath()

    if ($Url) {
        $fileName = Split-Path -Leaf $Url
        Write-Host "Downloading $Url to $packageLocationPat\$fileName"
        curl $Url --output "$packageLocationPath\$fileName"
        $expression = "$expression --source $packageLocationPath"
    }

    $expression = "$expression `nexit `$LASTEXITCODE"

    Set-ExecutionPolicy Bypass -Scope Process -Force
    $packageScriptPath = [System.IO.Path]::GetTempFileName() + ".ps1"
    Set-Content -Value $expression -Path $packageScriptPath
    Write-Host "File path $packageScriptPath"

    Execute -File $packageScriptPath
    Remove-Item $packageScriptPath
    Remove-Item $packageLocationPath
}

function Execute
{
    [CmdletBinding()]
    param(
        $File
    )

    # Note we're calling powershell.exe directly, instead
    # of running Invoke-Expression, as suggested by
    # https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/avoid-using-invoke-expression?view=powershell-7.3
    # Note that this will run powershell.exe
    # even if the system has pwsh.exe.
    powershell.exe -File $File

    # capture the exit code from the process
    $processExitCode = $LASTEXITCODE

    # This check allows us to capture cases where the command we execute exits with an error code.
    # In that case, we do want to throw an exception with whatever is in stderr. Normally, when
    # Invoke-Expression throws, the error will come the normal way (i.e. $Error) and pass via the
    # catch below.
    if ($processExitCode -or $expError)
    {
        if ($processExitCode -eq 3010)
        {
            # Expected condition. The recent changes indicate a reboot is necessary. Please reboot at your earliest convenience.
        }
        elseif ($expError)
        {
            throw $expError
        }
        else
        {
            throw "Installation failed with exit code: $processExitCode. Please see the Chocolatey logs in %ALLUSERSPROFILE%\chocolatey\logs folder for details."
            break
        }
    }
}

###################################################################################################
#
# Main execution block.
#

Write-Host 'Ensuring latest Chocolatey version is installed.'
Ensure-Chocolatey -ChocoExePath "$Choco"

if ($BypassProxy -eq "true") {
    Write-Host 'Bypassing proxy settings for this installation.'
    (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $webclient.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1';
    (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $client.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1';
    (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $client.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1';
}

try {
    Write-Host "Preparing to install Chocolatey package: $Package."
    Write-Host "Command: $Choco -Package $Package -Version $Version -Switches $Switches -IgnoreChecksums $IgnoreChecksums" 
    Install-Package -ChocoExePath "$Choco" -Package $Package -Version $Version -Switches $Switches -IgnoreChecksums $IgnoreChecksums -Url $Url

    Write-Host "`nThe artifact was applied successfully.`n"
} finally {
    if ($BypassProxy -eq "true") {
        Write-Host 'Restoring proxy settings for this installation.'
        (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1') -replace '; \$webclient.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1';
        (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1') -replace '; \$client.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1';
        (Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1') -replace '; \$client.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1';
    }
}
