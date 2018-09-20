function Add-SPLListText{
    <#
            .Synopsis
            Add key field to a sharepoint list

            .Description
            Add a key field to a sharepoint list with parameters

            .Parameter ListName
            Name of the list where the new field is created

            .Parameter Name
            Name of the new field

            .Parameter Caption
            Caption for the new field. If omitted the name becomes the caption

            .Parameter Description
            Description for the new field

            .Parameter MaxLength
            MaxLength for the new field. If omitted the default is 12.

            .Parameter Mandatory
            Force field as mandatory. A value is needed for this field.

            .Parameter Unique
            Force field to be unique in the list

            .Example
            Add-SPLListText   -ListName $ListName -Name 'L2Key' -Caption 'L2 Key' -MaxLength 12 -Description 'Enter Key value for this record' -Mandatory

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [String]$Default=$null,
        [String]$Caption=$null,
        [String]$Description=$null,
        [int]$MaxLength=255,
        [switch]$Mandatory,
        [switch]$Unique,
        [switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Text)"
    $text = '<Field
        Type="Text"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        MaxLength="{2}"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Key Values"/>' -f $Name, $Caption, $MaxLength
    $xml =[xml]$text


    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Unique)       {$xml.Field.SetAttribute("Indexed",             "TRUE"),
    $xml.Field.SetAttribute("EnforceUniqueValues", "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Default)      {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
}
