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
        $Fields = $List.Fields #.GetEnumerator() | ForEach-Object { $_ }

        function CsvItem($Item) {
            if ($Item) {
                if ($item -is [String]) {
                    $del + ([String]$Item).Replace($del, $del+$del).Replace("`r"," ").Replace("`n"," ") + $del
                } elseif ($item -is [DateTime]) {
                    $Item.ToString('yyyy-MM-dd HH:mm:ss')
                } else {
                    $Item.ToString()
                }
            }
        }

        function CsvText($Item, $Field) {
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
                        'Id'    {
                                    if ($Field.Size) {
                                        if ($Field.Size -eq "int") {
                                            [int]$val = $Item.LookupValue
                                            $val
                                        } else {
                                            $Item.LookupValue
                                        }
                                    } else {
                                        $Item.LookupId
                                    }
                                    break
                                }
                        Default {$Item.LookupValue; break}
                    }
                #} elseif ($Item -is [Int]) {
                #    $Item
                } else {
                    $Item
                }
            } 
            else
            {
                $Item
            }
        }
        function CsvValue($Item, $Field) {
            if ($Item) {
                if ($Item -is [System.Array]) {
                    if($item.Count -eq 0) {
                        CsvItem $null
                    } elseif($item.Count -eq 1) {
                        CsvItem (CsvText $Item[0] $Field)
                    } else {
                        $Text = $null
                        foreach ($Value in $Item)
                        {
                            if ($Text) {$Text += ";"}
                            $Text += (CsvText $Value $Field).ToString()
                        }
                        CsvItem $Text
                    }
                } else {
                    CsvItem (CsvText $Item $Field)
                }
            }
        }
        function WriteHeader{
            $Line = $null
            foreach ($Field in $Fields)
            {
                if ($Line) {$Line += $sep}
                $Line += CsvItem $Field.$UseName
            }
            $Line
            Write-Verbose $Line
        }

        function WriteData($Names,[Hashtable]$Items){
            $Line = $null
            foreach ($Field in $Fields)
            {
                if ($Line) {$Line += $sep}
                $Line += CsvValue $Items[$Field.$UseName] $Field
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
            Write-Progress -Activity ("Write {0}" -f $List.Name) -Status "Progress:" -PercentComplete ($I/$List.Items.count*100)
        }
    }

    end {
        $Lines
    }
}

