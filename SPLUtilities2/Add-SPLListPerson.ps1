function Add-SPLListPerson{
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
            Add-SPLListPerson   -ListName $ListName -Name 'Responsible' -Description 'Enter Responsible person for this record'

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [String]$Default=$null,
        [String]$Caption=$null,
        [String]$Description=$null,
        [switch]$Mandatory,
        [switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Person)"
    $text = '<Field
        Type="User"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        List="UserInfo"
        UserSelectionMode="PeopleOnly"
        UserSelectionScope="0"
        ShowField="ImnName"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Data Values"/>' -f $Name, $Caption
    $xml =[xml]$text

    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Default)      {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
}
