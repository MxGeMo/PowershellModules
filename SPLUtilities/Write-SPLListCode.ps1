<#
        .SYNOPSIS
        Write List definition code 
        .EXAMPLE
        Write-SPLListCode -List CATL2 -Code PowerQueryM
#>
function Write-SPLListCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$List,

        [ValidateSet(
                'Default',
                'PowerQueryM', 
                'MsAccessView', 
                'OracleTable', 
                'OracleLoader'
        )]
        [String]$Code='Default',

        [ValidateRange(1,9)]
        [int]$DS=1,
        
        [switch]$Date
    )
    begin{
        [xml]$doc = Get-SPLListsConfig
        foreach($id in ('Name', 'Title', 'GUID', 'Oracle')) {
            $SpList = $doc.SelectSingleNode(('/SharePointListsConfig/Lists/List[@{0}="{1}"]' -f $id, $List))
            if ($SpList) {break}
        }
        if (!$SpList) {Write-Error ("List '{0}' is not found" -f $List); break}
        $Fields = Get-SPLListFieldsNumbered -List $SpList.GUID -DS $DS -Date:$Date #-Verbose

        function Get-OraType{
            param([String]$Type, 
            [int]$Size)
            switch -Regex ($Type)
            {
                "Number"            { 
                    if ($Size -gt 0) {'NUMBER({0})' -f $Size} else {'NUMBER(10)'}
                    break
                }
                "Counter|Lookup|User"            { 
                    if ($Size -gt 0) {'VARCHAR2({0})' -f $Size} else {'NUMBER(10)'}
                    break
                }
                "Text"           { 
                    'VARCHAR2({0})' -f $Size
                    break
                }      
                "Note"           { 
                    'VARCHAR2(4000)'
                    break
                }      
                "DateTime"           { 
                    'DATE' 
                    break
                }      
                "Calculated"           { 
                    if ($Size -gt 0) {'VARCHAR2({0})' -f $Size} else {'VARCHAR2(255)'}
                    break
                }      
                "Choice"           { 
                    if ($Size -gt 0) {'VARCHAR2({0})' -f $Size} else {'VARCHAR2(30)'}
                    break
                }      
                default      { 
                    $Type
                }
            }
        }
    }
    process{
        switch ($Code) {

            'Default' {
                foreach($Field in $Fields) {
                    "{0} of {1}:{2}: {3} {4}" -f $Field.ItemNr, $Field.Items, $Field.ItemCase, $Field.Name, $Field.Type
                }
            Break}

            'PowerQueryM' {
                $Fields2 = $Fields | ForEach-Object { if ($_.Name -ne $_.InternalName) {$_}} | Add-ListNumbers
                foreach($Field in $Fields2) {
                    "{0} of {1}:{2}: {3} {4}" -f $Field.ItemNr, $Field.Items, $Field.ItemCase, $Field.Name, $Field.InternalName
                }
            Break}

            'MsAccessView' {
                foreach($Field in $Fields) {
                    $Text = ("[{0}]," -f $Field.Title)
                    switch ($Field.ItemCase) {
                        1 {"Select T.{0} as [{1}]," -f $Text.PadRight(33), $Field.Name; break}
                        2 {"       T.{0} as [{1}]," -f $Text.PadRight(33), $Field.Name; break}
                        3 {"       T.{0} as [{1}]"  -f $Text.PadRight(33), $Field.Name; break}
                    }
                }
                " FROM [{0}] AS T" -f $SpList.Title
            Break}

            'OracleTable' {
                "CREATE TABLE {0} (" -f $SpList.Oracle
                foreach($Field in $Fields) {
                    [string]$Name =  $Field.Oracle
                    [string]$Type = Get-OraType $Field.Type $Field.Size
                    switch ($Field.ItemCase) {
                        1 {$Type += ',' ; break}
                        2 {$Type += ',' ; break}
                        3 {$Type += ');'; break}
                    }
                    "   {0} {1} -- {2}" -f $Name.PadRight(31), $Type.PadRight(32), $Field.Type
                }
            Break}
            'OracleLoader' {
                "options (skip=2, silent=(DISCARDS))"
                "load data truncate"
                "into table {0} fields terminated by ';' optionally enclosed by '`"'  trailing nullcols" -f $SpList.Oracle
                "("
                foreach($Field in $Fields) {
                    if ($Field.ItemCase -lt 3) {$Delimiter=','} else {$Delimiter=''}
                    if ($Field.Type -eq "DateTime") {
                        $Escape = ("`"to_date(:{0},'YYYY-MM-DD HH24:MI:SS')`"" -f $Field.Oracle) 
                    } else {
                        if ($Field.Escape -eq "1") {$Escape = ('"unesc(:{0})"' -f $Field.Oracle ) } else {$Escape=''}
                    }
                    if ($Escape) {
                       "    {0} {1}{2}" -f  $Field.Oracle.PadRight(32), $Escape, $Delimiter
                    } else {
                       "    {0}{1}" -f  $Field.Oracle,  $Delimiter
                    }
                }
                ")"
            Break}
        }
    }
    end{}
}

<#
        Name         : SPOC
        Caption      : SPOC
        Oracle       : SPOC
        Title        : SPOC
        InternalName : SPOC
        Type         : Lookup
        Size         : 
        Escape       : 
        DS           : 1
        ItemNr       : 9
        Items        : 9
        ItemCase     : 3
#>
