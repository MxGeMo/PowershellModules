function Connect-SpMxGeMo {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
		[ValidateSet(
            'MasterData', 
            'RM', 
            'RM2'
        )][String]$Site='MasterData'
	)
	[String]$SiteUrl = 'https://mxgemo.sharepoint.com/sites/cn'
	[String]$SiteLoc = "$MyBase\Data\MxGeMo"
	[String]$SubSite = ""

    switch ($Site) {
        "MasterData" { $SubSite = "MasterData"; Break}
        "RM" 		 { $SubSite = "MasterData/RM"; Break}
        "RM2" 		 { $SubSite = "MasterData/RM2"; Break}
    }
	$SiteUrl += "/" + $SubSite
	$SiteLoc += "\" + $SubSite.Replace("/","\")
    if ($pscmdlet.ShouldProcess("$SiteUrl", "Connect")){
	    $Url = Connect-SPSite -Url $SiteUrl
	    Check-Folder $SiteLoc | Set-Location
        "Url $Url"
        "Loc $SiteLoc"
    }
}