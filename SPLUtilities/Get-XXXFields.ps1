<#
        Get-PnPField -list List1 | 
        Where-Object Internalname -notin Title | 
        Sort-Object Internalname |
        ForEach-Object  { "  '{0}', ``" -f $_.InternalName  } | clip
#>
. "$MxProfile\Convert-SPLFieldName.ps1"

function Get-SPLFields {

    <#
            .SYNOPSIS 
            Get user defined fields of a sharepoint list

            .DESCRIPTION
            Get Get-PnPField and exclude internal fields from result

            .PARAMETER ListName
            ListName Name of the List

            .EXAMPLE
            Get-SPLFields -List List1

            .EXAMPLE
            Get-SPLFields 'Responsibility Matrix' | Select-Object -Property * | Out-GridView

            .EXAMPLE
            Get-SPLFields WCL1 | Select-Object -Property InternalName, Title, TypeAsString, MaxLength

            .EXAMPLE
            Get-SPLFields WCL1 | Select-Object -Property InternalName, Title, TypeAsString, MaxLength, Description | Out-GridView

            .EXAMPLE
            Get-SPLFields WCL2 | Sort-Object TitleOrg | Select-Object -Property Title, TitleOrg, Internalname, TypeAsString, MaxLength | Out-GridView
            Get-SPLFields WCL2 | Sort-Object TitleOrg | Select-Object * | Export-Csv -Path "C:\Users\mg048388\Desktop\WCL2.csv" -Delimiter ";" -Encoding UTF8
    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List
    )

    $ExcludeFields = Get-SPLExcludeFields

    Get-PnPField -list $List | 
    Where-Object InternalName -notin $ExcludeFields |
    Sort-Object InternalName | 
    Foreach-Object {
        $AdjText = Convert-SPLFieldName $_.InternalName

        #$obj = New-Object -typename PSObject
        #$obj | 
        #	Add-Member -membertype NoteProperty -name Title           -value ($_.Title) -passthru |
        #	Add-Member -membertype NoteProperty -name InternalName    -value ($_.InternalName) -passthru | 
        #	Add-Member -membertype NoteProperty -name InternalNameAdj -value ($AdjText) -passthru 

        $_ | Add-Member -membertype NoteProperty -name TitleOrg -value $AdjText -passthru
    }
}

function Get-SPLFieldsNr {
    <#
            .SYNOPSIS 
            Get user defined fields of a sharepoint list added with NrA and NrD

            .DESCRIPTION
            Get user defined fields of a sharepoint list added with NrA and NrD

            .PARAMETER List
            Name of the List

            .EXAMPLE
            Get-SPLFieldsNr -List 'CAT L1 Master Category' | Select-Object -Property InternalName, Title, TitleOrg, NrA, NrD, UseName

            .EXAMPLE
            Get-SPLFieldsNr -List 'CAT L1 Master Category' -NameCase Adjust | Select-Object -Property InternalName, Title, TitleOrg, NrA, NrD, UseName
    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List,
        [hashtable]$Translation,
        [hashtable]$Target,
        [ValidateSet('Default', 'Adjust', 'Title')][String]$NameCase
    )
    $Items = Get-SPLFields -list $List 
    $Count = $items.Count
    $NrA = 0
    $Items | Foreach-Object {
        $NrA++
        $NrD = $Count - $NrA + 1
        $UseName=$null
        if ($Translation) {
            $UseName = $Translation[$_.InternalName]
        }
        if (!$UseName) {
            if ($NameCase -eq 'Adjust') {
                $UseName = Convert-SPLFieldName $_.InternalName
            } elseif ($NameCase -eq 'Title') {
                $UseName = $_.Title
            } else {
                $UseName = $_.InternalName
            }
        }
        $TargetName=$null
        if ($Target) {
            $TargetName = $Target[$_.InternalName]
        }
        if (!$TargetName) {
            $TargetName = $_.InternalName
        }
        $_ | 
        Add-Member -membertype NoteProperty -name NrA        -value $NrA        -passthru |
        Add-Member -membertype NoteProperty -name NrD        -value $NrD        -passthru |
        Add-Member -membertype NoteProperty -name UseName    -value $UseName    -passthru |
        Add-Member -membertype NoteProperty -name TargetName -value $TargetName -passthru 
    }
}
function Get-SPLFieldsTable {

    <#
            .SYNOPSIS 
            Get user defined fields of a sharepoint list as MS Access SQL

            .DESCRIPTION
            Get SPLFieldsTable and exclude internal fields from result

            .PARAMETER List
            ListName Name of the List

            .EXAMPLE
            Get-SPLFieldsTable -List 'CAT L1 Master Category' -NameCase Adjust

    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List,
        [hashtable]$Translation,
        [hashtable]$Target,
        [ValidateSet('Default','Adjust','Title')][String]$NameCase='Default'
    )
    Get-SPLFieldsNr -list $List -Translation $Translation -Target $Target -NameCase $NameCase | Foreach-Object {      
        if ($_.NrA -eq 1) {$prefix = "@{ "} else {$prefix = "   "}
        if ($_.NrD -ne 1) {$suffix = ";"} else {$suffix = "}"}
        $Name1 = ("'{0}'" -f $_.UseName).PadRight(34)
        $Name2 = ("'{0}'{1}" -f (Convert-SPLFieldName $_.TargetName -Skip), $suffix).PadRight(33)
        "{0}{1} = {2} # {3}" -f $prefix, $Name1, $Name2 , $_.Title
    }
}
function Get-SPLFieldsMsAccessSql {
    <#
            .SYNOPSIS 
            Get user defined fields of a sharepoint list as MS Access SQL

            .DESCRIPTION
            Get SPLFieldsMsAccessSql and exclude internal fields from result

            .PARAMETER List
            Name or GUID of the List

            .EXAMPLE
            Get-SPLFieldsMsAccessSql -List 'CAT L1 Master Category'

            .EXAMPLE
            Get-SPLFieldsMsAccessSql -List af97989a-ebd9-496f-9c4b-d250001e60f5 -Target $CL1Names

    #> 
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List,
        [hashtable]$Target
    )
    Get-SPLFieldsNr -list $List -Target $Target -NameCase Title | Foreach-Object {  
        if ($_.NrA -eq 1) {$prefix = "SELECT "} else {$prefix = "       "}
        if ($_.NrD -ne 1) {$suffix = ","} else {$suffix = ""}
        "{0}Tab.[{1}] AS [{2}]{3}" -f $prefix, $_.UseName, $_.TargetName , $suffix
    }
    " FROM [{0}] As Tab" -f (Get-PnPList -Identity $List).Title
}

<#
    $items | Foreach-Object {  
        if ($_.NrD -ne 1) {$suffix = ","} else {$suffix = ""}
        '        {{"{0}","{1}"}}{2}' -f $_.UseName, $_.TargetName, $suffix
    }

#>

function Get-SPLFieldsPowerQueryM {
    param([
        Parameter(Mandatory = $true, ValueFromPipeline = $true)]$List,
        [hashtable]$Target
    )
    $items = Get-SPLFieldsNr -list $List -Target $Target -NameCase Adjust
    $items2 = $items | Foreach-Object {if ($_.UseName -ne $_.TargetName) {$_}}
    'let'
    '    Source = SharePoint.Tables("{0}", [ApiVersion = 15]),' -f (Get-PnPConnection).Url
    '    BaseTable = Source{{[Id="{0}"]}}[Items],' -f (Get-PnPList -Identity $List).Id
    '    BaseColumns = Table.SelectColumns(BaseTable,{'
    $items | Foreach-Object {  
        if ($_.NrD -ne 1) {$suffix = ","} else {$suffix = ""}
        '        "{0}"{1}' -f $_.UseName, $suffix
    }
    '        }),'
    '    BaseNames = Table.RenameColumns(BaseColumns,{'
    $nr = 0
    $items2 | Foreach-Object {  
        $nr++
        if ($Nr -ne $items2.count) {$suffix = ","} else {$suffix = ""}
        '        {{"{0}","{1}"}}{2}' -f $_.UseName, $_.TargetName, $suffix
    }
    '        })'
    'in'
    '    BaseNames'
}

#Get-SPLFieldsPowerQueryM -List af97989a-ebd9-496f-9c4b-d250001e60f5 -Target $CL1Names |clip