$InstallPath = 'C:\dev'

New-Item -ItemType Directory -Path $InstallPath | Out-Null
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + $InstallPath
