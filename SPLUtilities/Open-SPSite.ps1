function Open-SPSite
{
    [CmdletBinding(SupportsShouldProcess)]
    Param([ValidateSet('Site', 'Content', 'Setting', 'Structure', 'Permission', 'Base', 'Intern')][string]$Page='Site')

    $Url = Get-SPSite
    if(!$Url) {
        Write-Warning "Not connected to Sharepoint"
        return
    }
    $Base = ([regex]::Match($URL,'https://[^/]*/sites/[^/]*')).Value
    switch ($Page) {
        "Content"    { $Url += "/_layouts/15/viewlsts.aspx"; Break}
        "Setting"    { $Url += "/_layouts/15/settings.aspx"; Break}
        "Structure"  { $Url += "/_layouts/15/sitemanager.aspx?Source={WebUrl}_layouts/15/settings.aspx"; Break}
        "Permission" { $Url += "/_layouts/15/user.aspx"; Break}
        "Base"       { $Url = $Base; Break}
        "Intern"     { $Url = "$Base/internal"; Break}
    }
    if ($pscmdlet.ShouldProcess("$Url", "Open")){
        Write-Verbose ("Open {0}" -f $Url)
        Start-Process $Url
    }
}