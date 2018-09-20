function Write-SPLListData {
    <#
            .SYNOPSIS 
            Get data of a sharepoint list

            .DESCRIPTION
            Get data and exclude internal fields from result

            .PARAMETER ListName
            ListName Name of the List

            .EXAMPLE
            Write-SPLListData -ListName WCL1 -Verbose -UseName Name -OutputType XML -HideEmpty | Out-File WCL1.xml

            .EXAMPLE
            Write-SPLListData -ListName WCL1 -Verbose -UseName Name -OutputType Text -HideEmpty | Out-File WCL1.txt
            
            .EXAMPLE
            Write-SPLListData -ListName WCL1 -Verbose -Translation $WCL1Names -OutputType XML -HideEmpty | Out-File WCL1.xml
            ii WCL1.xml

            .EXAMPLE
            Write-SPLListData -ListName WCL1 -Verbose -Translation $WCL1Names -OutputType Text -HideEmpty | Out-File WCL1.txt
            ii WCL1.txt
            
    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List,
        
        [ValidateSet(
                'Text', 
                'XML', 
                'CSV'
        )][string]$OutputType="Text",
        
        [ValidateSet(
                'Name',
                'Caption', 
                'Oracle', 
                'Title', 
                'InternalName',
                'IntName'
        )][String]$UseName='Name',

        [ValidateRange(1,9)]
        [int]$DS=1,

        [switch]$HideEmpty
    )
    Begin {
        Write-Verbose ("Write-SPLListData Begin OutputType is {0}" -f $OutputType)



        [int]$Nr = 0
        [int]$StartMs = (Get-Date).Millisecond
        switch ($OutputType) {
            "XML"    {
                [xml]$doc = New-Object System.Xml.XmlDocument
                $dec = $Doc.CreateXmlDeclaration("1.0","UTF-8",$null)
                $null = $doc.AppendChild($dec)
                $root = $doc.CreateElement("dataroot")
                $null = $doc.AppendChild($root)
            }
            default {break}
        }
    } # End Begin block

    Process {
        Write-Verbose "Write-SPLListData Process"
        $ListItems = Get-SPLListData -list $Node.GUID 
        Get-PnPListItem -list $ListName | 
        Foreach-Object {
            $Nr++
            $Item = $_
            $fields = $Item.FieldValues
            switch ($outputType) {
                "XML"    {$rec = $doc.CreateElement($ListName) 
                    $null = $root.AppendChild($rec)
                break}
                default {"==== {0}: #{1}' ====" -f $ListName, $Item.ID; break}
            }
            foreach ($key in $fields.Keys) {
                if ($key -notin $ExcludeFields)
                {
                    [string]$name = $key
                    if ($Translation) {
                        $text = $Translation[$key]
                        if ($text) {
                            $name = $text
                        }
                    }
                    [string]$content = $fields[$key]
                    if ($content -eq 'Microsoft.SharePoint.Client.FieldLookupValue')
                    {
                        $content = $fields[$key].LookupValue
                    }
            
                    switch ($OutputType) {
                        "XML" {
                            [boolean]$output = $true
                            if ($HideEmpty) {if (!$content) {$output = $false}} 
                            if ($output)    {$dat = $doc.CreateElement($name)
                                $dat.InnerText =$content
                            $null = $rec.AppendChild($dat)}
                            break
                        }
                        default {"{0}: '{1}'" -f $name.PadRight(30), $content; break}
                    }
                }
            }
            switch ($OutputType) {
                "XML" {break}
                default {""; break}
            }
        }
    } # End of PROCESS block.

  
    End {
        switch ($OutputType) {
            "XML"    {$doc.OuterXml; break}
            default {break}
        }
        $Duration = $StartMs - (Get-Date).Millisecond 
        Write-Verbose ("Write-SPLListData End: Processed {0} items in {1} milliseconds" -f $Nr, $Duration)
    } # End of the End Block.


}
