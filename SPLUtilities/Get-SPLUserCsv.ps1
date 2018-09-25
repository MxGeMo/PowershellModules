function Get-SPLUserCsv {
    <#
            .SYNOPSIS 
            Get data of a sharepoint list            
    #> 
    [CmdletBinding()]
    param(
        [String]$Del='"',
        [String]$Sep=';'

    )
    begin {
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

        $users = Get-PnPUser 
        "Sep={0}" -f $Sep
        "{1}{0}{2}{0}{3}{0}{4}" -f $Sep, (CsvItem "ID"), (csvItem "Name"), (csvItem "Account"), (csvItem "Mail")
    }
    process {
        $users | ForEach-Object {
            "{1}{0}{2}{0}{3}{0}{4}" -f $Sep, (CsvItem $_.ID), (csvItem $_.Title), (csvItem $_.LoginName), (csvItem $_.EMail)
        }
    }
    end {}
}

