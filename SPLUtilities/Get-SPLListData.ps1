function Get-SPLListData {
    <#
            .SYNOPSIS 
            Get data of a sharepoint list

            .DESCRIPTION
            Get data and exclude internal fields from result

            .PARAMETER List
            Name of the List

            .PARAMETER UseName
            Select Name which is used for Items

            .PARAMETER List
            Name of the List

            .EXAMPLE
            $RML1 = Get-SPLListData -List RML1 -UseName Name -Verbose
            
    #> 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$List,
        
        [ValidateSet(
                'Name',
                'Caption', 
                'Oracle', 
                'Title', 
                'InternalName',
                'IntName'
        )]
        [String]$UseName='Name',

        [Switch]$NoData,

        [ValidateRange(1,9)]
        [int]$DS=1
    )
    Begin {
        [xml]$doc = Get-SPLListsConfig -Verbose:$False
        foreach($id in ('Name', 'Title', 'GUID')) {
            $Node = $doc.SelectSingleNode(('/SharePointListsConfig/Lists/List[@{0}="{1}"]' -f $id, $List))
            if ($Node) {break}
        }
        if (!$Node) {Write-Error ("List '{0}' is not found" -f $List); break}

        $Result = New-Object -TypeName PSObject -Property  @{      
            'Name'    = $Node.Name
            'GUI'     = $Node.GUID
            'Key'     = $Node.Key
            'Fields'  = $null
            'UseName' = $UseName
            'Names'   = $null
            'Items'   = $null
        }  

        $PrimaryKey=$node.Key
        $Result.Fields = Get-SPLListFieldsNumbered -List $Node.GUID -DS $DS
        
        $Result.Names = @{}
        if ($Result.Fields)
        {
            switch ($Result.UseName)
            {
                'Name' {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = $_.Name}
                break}
                'Caption' {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = $_.Caption}
                break} 
                'Oracle' {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = $_.Oracle}
                break}
                'Title' {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = $_.Title}
                break} 
                'IntName' {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = (Convert-SPLFieldName $_.InternalName -Verbose:$false)}
                break}
                Default {
                    $Result.Fields | ForEach-Object {$Result.Names[$_.InternalName] = $_.InternalName}
                break}
            }
        }
        else
        {
            Write-Error ("List {0} ({1}) has no fields! Check SharePointListsConfig.xml DS" -f $Node.Name, $Node.GUID)
        }
        Write-Verbose ("Use '{0}' for field names" -f $UseName)
        <#foreach($item in $Result.Names.GetEnumerator() | Sort-Object Value)
                {
                write-Verbose ("   {0} for '{1}'" -f ("'"+$item.Value+"'").PadRight(33),$item.Key)
        }#>

        [int]$Nr = 0
        $StartStamp = (Get-Date)
    } 

    Process {
        $Result.Items = Get-PnPListItem -list $Node.GUID | Foreach-Object {
            $Nr++
            $FieldValues = $_.FieldValues
            if (!$NoData)
            {
                $Data=@{}
                foreach($Field in $Result.Fields) {
                    $FieldName  = $Result.Names[$Field.InternalName]
                    if (!$FieldName) {$FieldName  = $Field.InternalName}
                    $FieldValue = $FieldValues[$Field.InternalName]
                    $Data[$FieldName]=$FieldValue
                }
            }
            $ID   = $FieldValues["ID"]
            $Key  = $FieldValues[$PrimaryKey]
            if (!$NoData) {
                $Item = New-Object -TypeName PSObject -Property  @{'Nr' = $Nr; 'ID' = $ID; 'Key'  = $Key; 'Item'=$Data}
            } else {
                $Item = New-Object -TypeName PSObject -Property  @{'Nr' = $Nr; 'ID' = $ID; 'Key'  = $Key}
            }
            $Item
        }
    }
    End {
        $Duration = (Get-Date)-$StartStamp 
        $Result
        Write-Verbose ("Get-SPLData End: Processed {0} items in {1}" -f $Nr, $Duration)
        Write-Verbose ""
    }
}

<#
    Connect-SpNokia RespMatrix
    $RML1 = Get-SPLListData -List RML1 -UseName Name -Verbose
    $RML2 = Get-SPLListData -List RML2 -UseName Name -Verbose
    $RML3 = Get-SPLListData -List RML3 -UseName Name -Verbose
    $RML4 = Get-SPLListData -List RML4 -UseName Name -Verbose
#>
