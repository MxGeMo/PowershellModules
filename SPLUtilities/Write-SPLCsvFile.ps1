function Write-SPLCsvFile {
    <#
            .SYNOPSIS 
            Get data of a sharepoint list            
    #> 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        $List,
        
        [ValidateSet(
                'Id',
                'Text',
                'Mail'
        )]
        [String]$Out='Id',
        [String]$Del='"',
        [String]$Sep=';'

    )
    begin {
        $UseName = $List.UseName
        $FieldNames = $List.Fields.GetEnumerator() | ForEach-Object { $_.$UseName }
        function CsvItem($Item) {
            if ($Item) {
                if ($item -is [String]) {
                    $del + ([String]$Item).Replace($del, $del+$del).Replace("`r"," ").Replace("`n"," ") + $del
                } else {
                    $Item.ToString()
                }
            }
        }

        function CsvText($Item) {
            if ($Item) {
                if ($Item -is [Microsoft.SharePoint.Client.FieldUserValue]) {
                    switch($Out)
                    {
                        'Id'    {$Item.LookupId;    break}
                        'Mail'  {$Item.EMail; break}
                        Default {$Item.LookupValue; break}
                    }
                } elseif ($Item -is [Microsoft.SharePoint.Client.FieldLookupValue]) {
                    switch($Out)
                    {
                        'Id'    {$Item.LookupId;    break}
                        Default {$Item.LookupValue; break}
                    }
                } else {
                    $Item
                }
            } 
            else
            {
                $Item
            }
        }
        function CsvValue($Item) {
            if ($Item) {
                if ($Item -is [System.Array]) {
                    if($item.Count -eq 0) {
                        CsvItem $null
                    } elseif($item.Count -eq 1) {
                        CsvItem (CsvText $Item[0])
                    } else {
                        $Text = $null
                        foreach ($Value in $Item)
                        {
                            if ($Text) {$Text += ";"}
                            $Text += (CsvText $Value).ToString()
                        }
                        CsvItem $Text
                    }
                } else {
                    CsvItem (CsvText $Item)
                }
            }
        }
        function WriteHeader{
            $Line = $null
            foreach ($FieldName in $FieldNames)
            {
                if ($Line) {$Line += $sep}
                $Line += CsvItem $FieldName
            }
            $Line
            Write-Verbose $Line
        }

        function WriteData($Names,[Hashtable]$Items){
            $Line = $null
            foreach ($FieldName in $FieldNames)
            {
                if ($Line) {$Line += $sep}
                $Line += CsvValue $Items[$FieldName]
            }
            $Line
        }

        $Lines = @()
    }

    process {
        $Lines += ("Sep={0}" -f $Sep)           
        $Lines += WriteHeader
        $I = 0
        foreach ($Row in $List.Items)
        {
            $I++
            $Lines += WriteData $List $Row.Item
            Write-Progress -Activity "Write File" -Status "Progress:" -PercentComplete ($I/$List.Items.count*100)
        }
    }

    end {
        $Lines
    }
}

