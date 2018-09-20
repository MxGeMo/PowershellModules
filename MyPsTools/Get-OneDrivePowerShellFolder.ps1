<#
        .Synopsis
        Get OneDrive PowerShell Folder 
        .DESCRIPTION
        Get OneDrive PowerShell Folder 
        .EXAMPLE
        Get-OneDrivePowerShellFolder
#>
function Get-OneDrivePowerShellFolder
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param([switch]$Warning)
    Begin
    {
        $Result = $null
    }
    Process
    {
        Get-ChildItem HKCU:\Software\Microsoft\OneDrive\Accounts | 
        ForEach-Object {
            $OneDriveUser = $_.GetValue("UserEMail")
            $UserFolder = $_.GetValue("UserFolder")
            $BaseFolder = "$UserFolder\PowerShell"
            if ((test-path $BaseFolder))
            {
                Write-Verbose ("Check OneDrive '{0}' ({1}) has '{2}'" -f  $UserFolder, $OneDriveUser, $BaseFolder)
                if (!$Result) {
                    $Result = $BaseFolder
                } else {
                    if ($Warning) {Write-Warning ("Check OneDrive '{0}' exist but is not selected" -f  $BaseFolder)}
                }
            }
            else 
            {
                Write-Verbose ("Check OneDrive '{0}' ({1})" -f  $UserFolder, $OneDriveUser)
            }
        }
    }
    End
    {
        $Result
    }
}
