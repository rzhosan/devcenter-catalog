(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $webclient.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1';
(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $client.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1';
(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1') -replace 'New-Object System.Net.WebClient', 'New-Object System.Net.WebClient; $client.Proxy = $null' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1';

# Replace back

(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1') -replace '; \$webclient.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFile.ps1';
(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1') -replace '; \$client.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebFileName.ps1';
(Get-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1') -replace '; \$client.Proxy = \$null', '' | Set-Content 'C:\ProgramData\chocolatey\helpers\functions\Get-WebHeaders.ps1';
