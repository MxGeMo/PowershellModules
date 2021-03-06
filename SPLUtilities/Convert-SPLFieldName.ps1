function Convert-SPLFieldName {
    <#
            .SYNOPSIS 
            Convert Sharepoint List Name
            .DESCRIPTION
            Convert Sharepoint List Name removing the hex values
            .PARAMETER Name
            Field Name
            .EXAMPLE
            Convert-SPLFieldName -Name '_x004b_ey2'
    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$Name,
        [switch]$Skip
        )
    $text = $Name
    Write-Verbose "Convert-SPLFieldName('$text')" 
    while ($text -match "_x([0-9a-f]{4})_") {
        $txt = $Matches[0]
        if ($Skip)
        {
            $text = $text.Replace($txt,'')
            Write-Verbose "   match '$txt' => Skip" 
        }
        else
        {
            $hex = $Matches[1]
            $val = [CONVERT]::toint16($hex,16)
            $chr = [CHAR][BYTE]$val
            $text = $text.Replace($txt,$chr)
            Write-Verbose "   match '$txt' => $hex => $val => $chr => '$text'" 
        }
    }
    $text
}
