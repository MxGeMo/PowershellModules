function Set-SPLListField{
    <#
            .SYNOPSIS
            Modifies title field of a sharepoint list

            .DESCRIPTION
            Modifies title field of a sharepoint list for Caption

            .Example
            Set-SPLListField -ListName XXXWCL2 -Name Title -Description "Das ist der Titel" -MaxLength 16

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [String]$Default=$null,
        [String]$Caption=$null,
        [Int16]$MaxLength=$null,
        [String]$Description=$null,
        [switch]$Mandatory,
        [switch]$NoMandatory,
        [switch]$Indexed,
        [switch]$NoIndexed,
        [switch]$Unique,
        [switch]$NoUnique
    )
    Write-Verbose "Mod '$ListName'.'$Name'"

    $Field = Get-PnPField -List $ListName -Identity $Name
    $xml   =[xml]$Field.SchemaXml

    if ($NoMandatory)     {$xml.Field.SetAttribute("Required",            "FALSE")}
    if ($NoIndexed)       {$xml.Field.SetAttribute("Indexed",             "FALSE")}
    if ($NoUnique)        {$xml.Field.SetAttribute("EnforceUniqueValues", "FALSE")}
    if ($Mandatory)       {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)         {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Unique)          {$xml.Field.SetAttribute("EnforceUniqueValues", "TRUE")
    $xml.Field.SetAttribute("Indexed",             "TRUE")}

    if ($Caption)         {"Modify Caption to '{0}' ('{1}')" -f  $Caption, $Field.Title | Write-Debug
    $xml.Field.SetAttribute("DisplayName", $Caption)}

    if ($MaxLength)       {"Modify MaxLength to {0} ({1})" -f $MaxLength, $xml.Field.MaxLength | Write-Debug
    $xml.Field.SetAttribute("MaxLength", $MaxLength)}

    if ($Description)     {"Modify Description to '{0}' ('{1}'))" -f $Description, $xml.Field.Description | Write-Debug
    $xml.Field.SetAttribute("Description", $Description)}
    if ($Default)         {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "SchemaXml: {0}" -f $xml.OuterXml | Write-Debug

    $null  = Set-PnPField -Identity $Field -Values @{SchemaXml=$xml.OuterXml}
    Get-PnPField -List $ListName -Identity "Title"
}
