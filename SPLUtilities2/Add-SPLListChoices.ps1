function Add-SPLListChoices{
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

            .Parameter Choices
            Array of choises for the new field.

            .Parameter Mandatory
            Force field as mandatory. A value is needed for this field.

            .Example
            Add-SPLListChoices -ListName aWCL2     -Name 'L2Status' -Caption 'L2 Status' -Choices 'Active', 'Inactive', 'Obsolete' -Default 'Active' -Description 'Enter Status' -Mandatory

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [Parameter(Mandatory = $true)][String[]]$Choices,
        [String]$Default=$null,
        [String]$Caption=$null,
        [String]$Description=$null,
        [Switch]$Mandatory,
        [Switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Choice)"
    $text = '<Field
        Type="Choice"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Key Values"/>' -f $Name, $Caption
    $xml =[xml]$text
    $xmlChoices = $xml.CreateElement("CHOICES")
    $xml.Field.AppendChild($xmlChoices)
    $null=$Choices | ForEach-Object {
        ($child = $xml.CreateElement("CHOICE")).InnerText=$_
        $xmlChoices.AppendChild($child)
    }

    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}
    if ($Default)      {($xmlDefault = $xml.CreateElement("Default")).InnerText=$Default
    $xml.Field.AppendChild($xmlDefault)}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
}
