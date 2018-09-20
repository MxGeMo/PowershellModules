function Add-SPLListCalc{
    <#
            .Synopsis
            Add calculation field to a sharepoint list

            .Description
            Add a calculation field to a sharepoint list with parameters

            .Parameter ListName
            Name of the list where the new field is created

            .Parameter Name
            Name of the new field

            .Parameter Formula
            Formula for the new field

            .Parameter Caption
            Caption for the new field. If omitted the name becomes the caption

            .Parameter Description
            Description for the new field

            .Example
            Add-SPLListCalc -ListName XXXWCL2 -Name 'CreatedText' -Caption 'Created Text' -Formula '=TEXT(Created,"yyyyMMdd")' -Fields 'Created'

            .Example
            Add-SPLListCalc -ListName XXXWCL2 -Name 'Test5' -Formula '=TEXT([Created],"yyyyMMdd") & " X " & [L2 ID]' -Fields 'Created','L2 ID'

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [Parameter(Mandatory = $true)][String]$Formula,
        [Parameter(Mandatory = $true)][String[]]$Fields,
        [Switch]$ResultNumber,
        [Switch]$ResultCurrency,
        [switch]$ResultDateTime,
        [switch]$ResultBoolean,
        [String]$Caption=$null,
        [String]$Description=$null
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Calculated)"
    $text = '<Field
        Type="Calculated"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        ResultType="Text"
        ReadOnly="TRUE"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Key Values"/>' -f $Name, $Caption

    $xml =[xml]$text

    $xml.Field.AppendChild($xml.CreateElement("Formula")).InnerText = $Formula

    $xmlFieldRefs = $xml.CreateElement("FieldRefs")
    $Fields | ForEach-Object {$xmlFieldRefs.AppendChild($xml.CreateElement("FieldRef")).SetAttribute("Name",$_)}
    $null = $xml.Field.AppendChild($xmlFieldRefs)

    if ($Description)    {$xml.Field.SetAttribute("Description",         $Description)}
    if ($ResultNumber)   {$xml.Field.SetAttribute("ResultType",          'Number')}
    if ($ResultCurrency) {$xml.Field.SetAttribute("ResultType",          'Currency')}
    if ($ResultDateTime) {$xml.Field.SetAttribute("ResultType",          'DateTime')}
    if ($ResultBoolean)  {$xml.Field.SetAttribute("ResultType",          'Boolean')}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml

}