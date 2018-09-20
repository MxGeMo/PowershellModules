<#
        Author:           Gerhard Morgenstein
        Version:          V1.0
        Version History:  

        Purpose:          Read-SPLListsFields to SharePointListsConfig.xml

        Read-SPLListsFields -Verbose
#>

function Read-SPLListsFields {
    [CmdletBinding()]
    param(
        #[Parameter(Mandatory = $true)][String]$Name,
        [switch]$SaveSchema
    )
    BEGIN
    {
        #Write-Verbose "Get-SPLLists BEGIN"
        $ExcludeFields = Get-SPLExcludeFields
        [xml]$doc = Get-SPLListsConfig
        #$root = $doc.DocumentElement
        $lists = $doc.SelectSingleNode("/SharePointListsConfig/Lists")
        #$SpecialFields = @{Author='CreatedBy';Editor='ModifiedBy';Last_x0020_Modified='ModifiedDate';Created_x0020_Date='CreationDate'}
        $SpecialFields = @{Author='CreatedBy';Editor='ModifiedBy';Modified='ModifiedDate';Created='CreationDate'}
        [xml]$Schema = New-Object System.Xml.XmlDocument
    }
    PROCESS
    {
        #Write-Verbose "Get-SPLLists PROCESS"
        $ListDir = @{}
        Get-PnPList | Where-Object DefaultViewUrl -Like '*List*' | ForEach-Object {
            $ListDir[$_.id]=$_.Title 
            $XPath = ('/SharePointListsConfig/Lists/List[@GUID="{0}"]' -f $_.id) 
            $list = $doc.SelectSingleNode($XPath)
            
            if (!$list)
            {
                Write-Verbose ("Add List {0}" -f $_.Title)
                $list = $lists.AppendChild($doc.CreateElement("List"))
                $list.SetAttribute("GUID", $_.id)
                $list.SetAttribute("Name", $_.Title)
                $list.SetAttribute("Oracle", (Get-OraName $_.Title -Verbose:$False))
                $list.SetAttribute("Process", 'No')
            }
            $list.SetAttribute("Title", $_.Title)
            if (!$list.attributes['Key'].value) {
                $list.SetAttribute("Key", "Title")
            }
        }
        $nodes = $doc.SelectNodes('/SharePointListsConfig/Lists/List[@Process="Yes"]')
        foreach ($node in $nodes) {
            $Name  = $node.attributes['Name'].value
            $Title = $node.attributes['Title'].value
            $GUID  = $node.attributes['GUID'].value
            if (!$node.attributes['Oracle'].value)
            {
                $OraName = Get-OraName $Name -Verbose:$False
                Write-Verbose ("Set Oracle {0} {1} ({2})" -f $GUID, $Name, $OraName)
                $node.SetAttribute("Oracle", $OraName )
            }

            Write-Verbose ("Process {0} {1} ({2})" -f $GUID, $Name, $Title)
            $fields =Get-PnPField -List $GUID | Where-Object InternalName -notin $ExcludeFields 
            $fields | ForEach-Object { 
                $Schema.LoadXml($_.SchemaXml)
                $SpecialField = $SpecialFields[$_.InternalName]
                $AdjText      = Convert-SPLFieldName $_.InternalName -Verbose:$false
                $XPath        = ('Field[@GUID="{0}"]' -f $_.id)
                $field        = $node.SelectSingleNode($XPath)
                if (!$field) 
                {
                    Write-Verbose ("    Add Field {0}" -f $_.Title)
                    $field = $node.AppendChild($doc.CreateElement("Field"))
                    $field.SetAttribute("GUID", $_.id)
                    if ($SpecialField) 
                    {
                        $field.SetAttribute("DS", '-1')
                        $field.SetAttribute("Name", $SpecialField)
                        $field.SetAttribute("Caption", $_.Title)
                        $field.SetAttribute("Oracle", (Get-OraName $SpecialField -Verbose:$False))
                    }
                    else 
                    {
                        $field.SetAttribute("DS", '0')
                        $field.SetAttribute("Name", $AdjText)
                        $field.SetAttribute("Caption", $_.Title)
                        $field.SetAttribute("Oracle", (Get-OraName $AdjText -Verbose:$False))
                    }
                }
                #if (!$field.attributes['Oracle'].value) {$field.SetAttribute("Oracle", (Get-OraName $field.attributes['Name'].value -Verbose:$False))}
                #if ($SpecialField) {$field.SetAttribute("Title", $SpecialField)} else {$field.SetAttribute("Title", $_.Title)}
                $field.SetAttribute("Title", $_.Title)
                $field.SetAttribute("InternalName", $_.InternalName)

                $field.SetAttribute("Type", $_.TypeAsString)
                $field.SetAttribute("Required", $_.Required)
                $field.SetAttribute("Indexed", $_.Indexed)
                $field.SetAttribute("Unique", $_.EnforceUniqueValues)
                $field.SetAttribute("ReadOnly", $_.ReadOnlyField)
                $field.SetAttribute("Default", $Schema.Field.Default)
                if ($_.TypeAsString -eq "Text") { $field.SetAttribute("Escape", "0")}
                if ($_.TypeAsString -eq "Text")   { $field.SetAttribute("Size", $_.MaxLength)}
                $field.InnerXML = ''
                if ($SaveSchema) {
                    $field.InnerXML = $Schema.OuterXml
                } elseif ($_.TypeAsString -eq "Choice") {
                    $field.InnerText = $Schema.Field.CHOICES.InnerXml.Replace('</CHOICE><CHOICE>',', ').Replace('<CHOICE>','').Replace('</CHOICE>','')
                } elseif ($_.TypeAsString -eq "Calculated") {
                    $field.InnerText = $Schema.Field.Formula
                } elseif ($_.TypeAsString -eq "Lookup") {
                    $LookupField = $_.LookupField
                    $LookupList  = $_.LookupList.Replace('{','').Replace('}','')
                    if ($LookupList) {
                        $LookupRef   = $_.LookupRef
                        $LookupName  = $ListDir[$LookupList] #funktioniert nicht
                        if(!$LookupName) {$LookupName = $LookupList}
                        $field.InnerText = ("{0} : {1} {2}" -f $LookupName, $LookupField, $LookupRef )
                     }
                     else
                     {
                        $field.InnerText =$LookupField 
                        #if ($LookupField -in 'TimeLastModified','TimeCreated') 
                        #{
                        #    $field.SetAttribute("Type", "Date")
                        #}
                     }
                }

        
            }
        }
    }
    END 
    {
        #Write-Verbose "Get-SPLLists END"
        $filename = Get-SPLListsConfigPath
        $doc.Save($filename)
        #Write-Verbose ("Save {0}" -f $Filename)
        #$Filename
    }
}

function Show-SPLListsFields {
    [CmdletBinding()]
    param(
        [ValidateRange(1,9)][int]$DS=1
    )
    begin{
        [xml]$doc = Get-SPLListsConfig
        $lists = $doc.SelectNodes('/SharePointListsConfig/Lists/List')
        if ($lists.Count -eq 0) {Write-Error "No list found"; break}
        $nodes = $doc.SelectNodes('/SharePointListsConfig/Lists/List[@Process="Yes"]')
        if ($nodes.Count -eq 0) {Write-Error ("No active list of {0} list" -f $lists.Count); break}
    }
    process {
        foreach ($node in $nodes) {
            $data = 1 | Select-Object -Property Name, Fields
            $data.Name = $node.Name
            $data.Fields = ""
            foreach ($Field in $Node.Field) {
                if (($Field.DS -gt 0) -and ($Field.DS -le $DS))
                {
                    if ($data.Fields) {$data.Fields += ", "}
                    $data.Fields += $Field.Name
                }
            }
            $data
        }
    }
}
