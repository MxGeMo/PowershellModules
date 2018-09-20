function Set-SPLFieldReadOnly {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][String]$List,
        [Parameter(Mandatory)][String[]]$Identity,
        [Switch]$ReadOnly
    )
    begin {
        $ctx = Get-PnPContext
        Write-Verbose ("Set List {0} on {1}" -f $List, $ctx.Url)
    }
    process {
        foreach ($Item in $Identity)
        {
            $Field = Get-PnPField -List $List -Identity $Item 
            if($PSCmdlet.ShouldProcess(("{0}.{1}" -f $List, $item),("Readonly = {0}" -f $ReadOnly) )){
                $Field.ReadOnlyField = $ReadOnly
                $Field.UpdateAndPushChanges($True)
                $ctx.ExecuteQuery()
                Write-Verbose ("Set {0}.{1}.Readonly = {2}" -f $List, $Item, $ReadOnly)
                Get-PnPField -List $List -Identity $Item
            }
        }
    }
}
