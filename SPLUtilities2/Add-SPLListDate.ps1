function Add-SPLListDate{
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

            .Parameter Mandatory
            Force field as mandatory. A value is needed for this field.

            .Example
            Add-SPLListDate -ListName XXXWCL2     -Name 'CreDate' -Description 'Enter date of category creation' -Mandatory

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [String]$Default=$null,
        [String]$Caption=$null,
        [String]$Description=$null,
        [switch]$Mandatory,
        [Switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Date)"
    $text = '<Field
        Type="DateTime"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        Format="DateOnly"
        FriendlyDisplayFormat="Disabled"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Key Values"/>' -f $Name, $Caption
    $xml =[xml]$text

    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Default)      {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
}
