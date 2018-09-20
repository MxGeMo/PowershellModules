function Get-SPSite {
    [CmdletBinding()]
    Param()
    begin 
    { 
        $url = $null
    }
    process 
    {
        try
        {
            $url = $(Get-PnPContext).Url
            Write-Verbose ("Session is connected to URL {0}" -f $url)
        }
        catch
        {
            Write-Verbose "Not connected to Sharepoint"
        }
    }
    end 
    {
        $url
    }
}
