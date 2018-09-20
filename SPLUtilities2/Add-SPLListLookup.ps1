function Add-SPLListLookup{
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
            Add-SPLListNumber   -ListName $ListName -Name 'Parent' -List (Get-PnPList WCL1).Id

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][String]$ListName,
        [Parameter(Mandatory = $true)][String]$Name,
        [Parameter(Mandatory = $true)][String]$Lookup,
        [String]$Field="Title",
        [String[]]$Fields=$null,
        [String]$Caption=$null,
        [String]$Description=$null,
        [switch]$Mandatory,
        [switch]$Indexed
    )

    if (!$Caption) {$Caption = $Name}
    Write-Verbose "Add '$ListName'.'$Name' as '$Caption' (Lookup from $Lookup)"

    $text = '<Field
        Type="Lookup"
        Name="{0}"
        StaticName="{0}"
        DisplayName="{1}"
        List="{2}"
        ShowField="{3}"
        Description=""
        Required="FALSE"
        Indexed="FALSE"
        EnforceUniqueValues="FALSE"
    Group="Lookup Values"/>' -f $Name, $Caption, $Lookup, $Field
    $xml =[xml]$text

    if ($Description)  {$xml.Field.SetAttribute("Description",         $Description)}
    if ($Mandatory)    {$xml.Field.SetAttribute("Required",            "TRUE")}
    if ($Indexed)      {$xml.Field.SetAttribute("Indexed",             "TRUE")}

    "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

    $Item = Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml

    if ($Fields) {
        $Fields | ForEach-Object {
            $items=$_.Split('=')

            switch ($items.Count) {
                1 {
                    $refField=$items[0]
                    $refName=$items[0]
                    $refDisp=$items[0]
                break}
                2 {
                    $refField=$items[0]
                    $refName=$items[1]
                    $refDisp=$items[1]
                break}
                default {
                    $refField=$items[0]
                    $refName=$items[1]
                    $refDisp=$items[2]
                break}
            }

            $xml.Field.SetAttribute("Name",                $refName)
            $xml.Field.SetAttribute("StaticName",          $refName)
            $xml.Field.SetAttribute("DisplayName",         $refDisp)
            $xml.Field.SetAttribute("Description",         "Lookup from WCL1")
            $xml.Field.SetAttribute("FieldRef",            $Item.Id)
            $xml.Field.SetAttribute("ShowField",           $refField)

            "FieldXml: {0}" -f $xml.OuterXml | Write-Debug

            Write-Verbose "Add '$ListName'.'$refName' as '$refDisp' (Lookup from $Lookup - '$refField')"
            $SubItem = Add-PnPFieldFromXml -List $ListName -FieldXml $xml.OuterXml
        }
        $Item
    }

}
