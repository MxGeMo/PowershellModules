<#

Author:           Gerhard Morgenstein
Version:          V1.0
Version History:  

Purpose:          Checks if a folder exist or create the folder

#>

function Check-Folder {
<#
.Synopsis
   Test and create folder 
.DESCRIPTION
   Checks if a folder exist or create the folder
.EXAMPLE
   Check-Folder 
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Path
    )

    Begin
    {
    }
    Process
    {
      If(!(test-path $Path))
      {
            New-Item -ItemType Directory -Force -Path $Path -Verbose:$VerbosePreference
      } else {
            Get-Item -Path $Path -Verbose:$VerbosePreference
      }
    }
    End
    {
    }
}
<#
Check-Folder $MyBase\Data\MasterData\Categories\Test3 | Set-Location
ls ..
#>