<#
        .Synopsis
        Add ItemNr and Items
        .DESCRIPTION
        Use items from pipe and numbers add ItemNr and Items to the list
        .EXAMPLE
        ls | Sort-Object Name | Add-ListNumbers | Select-Object -Property ItemNr, Items, Name
#>
function Add-ListNumbers
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Value help description
        [Parameter(Mandatory=$true,
                ValueFromPipeline=$true,
        Position=0)]
        $Value
    )

    Begin
    {
        $Items = @()
    }
    Process
    {
        $Items += $Value
    }
    End
    {
        $ItemsNr = 0
        foreach($Item in $Items)
        {
            $ItemsNr++
            if ($ItemsNr -eq 1)
            {
                $ItemsCase = 1
            }
            elseif ($ItemsNr -lt $Items.Count)
            {
                $ItemsCase = 2
            }
            else
            {
                $ItemsCase = 3
            }
            $Item | 
            Add-Member -membertype NoteProperty -name ItemNr   -value ($ItemsNr)     -Force -passthru |
            Add-Member -membertype NoteProperty -name Items    -value ($Items.Count) -Force -passthru |
            Add-Member -membertype NoteProperty -name ItemCase -value ($ItemsCase)   -Force -passthru 
        }
    }
}
