function Open-MxPath {
  param ([parameter(Mandatory=$true)][string]$path)
  $path.Split(';') |
    ForEach-Object { 
        if ([string]::IsNullOrEmpty($_)) {
            write-host "    empty" -ForegroundColor Red
        } else {
            if (Test-Path $_) {
                Invoke-Item $_
            }
        }
    }
}
function Show-MxPath {
  param ([parameter(Mandatory=$true)][string]$path)
  $path.Split(';') |
    ForEach-Object { 
        if ([string]::IsNullOrEmpty($_)) {
            write-host "    empty" -ForegroundColor Red
        } else {
            if (Test-Path $_) {
                write-host ("    {0}" -f $_) -ForegroundColor Green
            } else {
                write-host ("    {0}" -f $_) -ForegroundColor Red
            }
        }
    }
}

function Open-MxPsModulePath {
  Open-MxPath $env:psmodulePath
}

function Open-MxWindowsPath {
  Open-MxPath $env:Path
}

function Show-MxPsModulePath {
  Write-Host "Show PSModule Path:"
  Show-MxPath $env:psmodulePath
  Write-Host ""
}
function Show-MxWindowsPath {
  Write-Host "Show Windows Path:"
  Show-MxPath $env:Path
  Write-Host ""
}
