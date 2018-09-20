function Add-SPLListNumber{
    <#
            .Synopsis
            Add Person field to a sharepoint list

            .Description
            Add a Person field to a sharepoint list with parameters

            .Parameter ListName
            Name of the list where the new field is created

            .Parameter Name
            Name of the new field

            .Parameter Caption
            Caption for the new field. If omitted the name becomes the caption

            .Parameter Description
            Description for the new field

            .Parameter Mandatory
            Force field as mandatory. A value is needed for this field.

            .Example
            Add-SPLListNumber   -ListName $ListName -Name 'Rang' -Description 'Enter ranking Number'

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [String]$Default=$null,
        [int]$MinValue=$null,
        [int]$MaxValue=$null,
        [int]$Decimals=0,
        [String]$Caption=$null,
        [String]$Description=$null,
        [switch]$Mandatory,
        [switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Number)"
    $text = '<Field
        Type="Number"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
        Decimals="0"
    Group="Data Values"/>' -f $Name, $Caption
    $xml =[xml]$text

    if ($Decimals)     {$xml.Field.SetAttribute("Decimals",            $Decimals)}
    if ($MinValue)     {$xml.Field.SetAttribute("Min",                 $MinValue)}
    if ($MaxValue)     {$xml.Field.SetAttribute("Max",                 $MaxValue)}

    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Default)      {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
}
