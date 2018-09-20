function Get-SPLListFields {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][String]$List,
        [ValidateRange(1,9)][int]$DS=1,
        [switch]$Date
    )
    begin {
        [xml]$doc = Get-SPLListsConfig
        foreach($id in ('Name', 'Title', 'GUID')) {
            $nodes = $doc.SelectNodes(('/SharePointListsConfig/Lists/List[@{0}="{1}"]' -f $id, $List))
            if ($Nodes.Count -ge 1) {break}
        }
        if ($nodes.Count -eq 0) {Write-Error ("List '{0}' is not found" -f $List); break}
        if ($Date) {[int]$MinDS = -1} else {[int]$MinDS = 0}
    }
    process {
        foreach ($node in $nodes) {
            #$node.Name
            foreach ($Field in $Node.Field) {
                if (([int]$Field.DS -ge $MinDS) -and ([int]$Field.DS -le $DS) -and ([int]$Field.DS -ne 0))
                {
                    Write-Verbose ("Use  '{0}' (DS: {1} < {2} < {3})" -f $Field.Name, $MinDS, $Field.DS,  $DS)
                    $data = 1 | Select-Object -Property Name, Caption, Oracle, Title, InternalName, Type, Size, Escape, DS
                    $data.Name         = $Field.Name
                    $data.Caption      = $Field.Caption
                    $data.Oracle       = $Field.Oracle
                    $data.Title        = $Field.Title
                    $data.InternalName = $Field.InternalName
                    $data.Type         = $Field.Type
                    $data.Size         = $Field.Size
                    $data.Escape       = $Field.Escape
                    $data.DS           = $Field.DS
                    $data
                } 
                else 
                {
                    Write-Verbose ("Skip '{0}' (DS: {1} < {2} < {3})" -f $Field.Name, $MinDS, $Field.DS,  $DS)
                }
            }
        }
    }
}

function Get-SPLListFieldsNumbered {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][String]$List,
        [ValidateRange(1,9)][int]$DS=1,
        [switch]$Date
    )
    Get-SPLListFields -List $list -DS $DS -Date:$Date | Add-ListNumbers

}


#Get-SPLListFields -List RML1 -DS 9 | Add-ListNumbers | Out-GridView
#Get-SPLListFieldsNumbered -List RML1 -DS 9 | Out-GridView
