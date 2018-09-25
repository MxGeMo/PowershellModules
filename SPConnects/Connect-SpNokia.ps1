function Connect-SpNokia {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
		[ValidateSet(
            'MasterData', 
            'Categories', 
            'CatPrepare',
            'RespMatrix', 
            'SupplierGroups',
            'SupplierGroupsOld',
            'PdmTypes',
            'TechGPMA',
            'Root'
        )][String]$Site='MasterData'
	)
	[String]$SiteUrl = 'https://nokia.sharepoint.com/sites/ProcurementIntelligence'
	[String]$SiteLoc = "$MyBase\Data\ProcurementIntelligence"
	[String]$SubSite = ""

    switch ($Site) {
        "MasterData"        { $SubSite = "MasterData"; Break}
        "Categories" 		{ $SubSite = "MasterData/Categories"; Break}
        "CatPrepare"        { $SubSite = "MasterData/Categories/Prepare"; Break}
        "RespMatrix"        { $SubSite = "MasterData/RM"; Break}
        "SupplierGroups"    { $SubSite = "MasterData/SupplierGroups"; Break}
        "SupplierGroupsOld" { $SubSite = "MasterData/RM2"; Break}
        "PdmTypes"          { $SubSite = "MasterData/PdmTypes"; Break}
        "Technical"         { $SubSite = "Tools/CIF/Technical"; Break}
        "TechGPMA"          { $SubSite = "Tools/CIF/Technical/Interfaces/GPMA"; Break}
    }
	$SiteUrl += "/" + $SubSite
	$SiteLoc += "\" + $SubSite.Replace("/","\")
    if ($pscmdlet.ShouldProcess("$SiteUrl", "Connect")){
	    $Url = Connect-SPSite -Url $SiteUrl -Verbose
	    Check-Folder $SiteLoc | Set-Location
        "Url $Url"
        "Loc $SiteLoc"
    }
}
