<#

Author:             Gerhard Morgenstein
Version:            1.0
Version History:

Purpose:  Convert Name to Oracle Identifier

#>

function Get-OraName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][String]$Name
    )
    begin {
        [int]$letterClass = $null
        [char[]]$chars = $name.ToCharArray()
        [String]$Result = ""
        [char[]]$upperLetter = [char[]]([char]'A'..[char]'Z')
        [char[]]$lowerLetter = [char[]]([char]'a'..[char]'z')
        [char[]]$numberLetter = [char[]]([char]'0'..[char]'9')
        [int]$MaxLength = 30
    }
    process {
        foreach($char in $chars){
            switch ($char)
            {
                {$_ -cin $upperLetter} {
                    if ($letterClass -and $letterClass -ne 1) {$result += "_"}
                    $result += $char
                    $letterClass = 1
                    break
                }
                {$_ -cin $lowerLetter} {
                    if ($letterClass -and $letterClass -gt 2) {$result += "_"}
                    $result += ([String]$char).ToUpper()
                    $letterClass = 2
                    break
                }
                {$_ -cin $numberLetter} {
                    if ($letterClass -and $letterClass -ne 3) {$result += "_"}
                    $result += $char
                    $letterClass = 3
                    break
                }
                Default {
                    if ($Result) {$letterClass = 4}
                    break
                }
            }
            
            
        }
    }
    end {
        if ($Result.Length -gt $MaxLength) {$Result = $Result.Substring(0,$MaxLength)}
        Write-Verbose ("{0} <= '{1}'" -f ("'"+$Result+"'").PadRight(32), $Name)
        $Result
    }
}