
function Get-MyPath {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$true)][string]$path,
    [Switch]$Invoke
  )
  $path.Split(';') |
    ForEach-Object { 
        if ([string]::IsNullOrEmpty($_)) {
            Write-Verbose "    empty" 
        } else {
            if (Test-Path $_) {
                Write-Verbose ("    {0} exists" -f $_) 
                $_
                if ($Invoke) {Invoke-Item $_}
            } else {
                Write-Verbose ("    {0} is not found" -f $_) 
            }
        }
    }
}

function Get-MyPsModulePath {
    [CmdletBinding()]
    param (
      [Switch]$Invoke
    )
    Get-MyPath $env:psmodulePath -Invoke:$Invoke
  Write-Host ""
}

function Get-MyWindowsPath {
    [CmdletBinding()]
    param (
      [Switch]$Invoke
    )
    Get-MyPath $env:Path -Invoke:$Invoke
  Write-Host ""
}
