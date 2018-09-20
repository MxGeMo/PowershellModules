function Connect-SPSite
{
    <#
            .SYNOPSIS 
            Connect to sharepoint site

            .DESCRIPTION
            Connect-SPSite to sharepoint site using credentials 

            .PARAMETER URL
            ListName Name of the List

            .EXAMPLE
            Connect-SPSite Connect-SPSite https://mxgemo.sharepoint.com/sites/cn/MasterData
    #> 

    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [string]
        $Url,

        # Param2 help description
        [hashtable]
        $CredentialList=$null
    )

    Begin
    {
        $CurrentSite = Get-SPSite
        $Credential  = $Null
    }
    Process
    { 
        if ($CurrentSite -eq $Url) 
        {
            Write-Verbose ("Session is already connected to URL {0}" -f $CurrentSite)
            return
        }
        if (!$CredentialList) 
        {
            if (Test-Path Variable:\SPCredentials)
            {
                try
                {
                    $CredentialList = $SPCredentials
                }
                catch
                {
                    Write-Error 'No Credentials parameter given and $SPCredentials is not set'
                    return
                }
            }
            
        }
        if ($CredentialList) 
        {
            $BaseUrl = ([regex]::Match($URL,'https://.*/sites/[^/]*')).Value
            $Credential = $CredentialList[$BaseUrl]
        }
        if ($Credential) 
        {
            switch ($Credential['typ'])
            {
                "User" 
                {
                    $user = $Credential['user']
                    if ($pscmdlet.ShouldProcess("$Url", ("Open as User " -f $user)))
                    {
                        $PasswordSecure = ConvertTo-SecureString -AsPlainText $Credential['secret'] -Force
                        $UseCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Credential['user'], $PasswordSecure
                        Write-Verbose ("Connect to {0} as User:{1}" -f $URL, $Credential['user'])
                        Connect-PnPOnline -Url $URL -Credentials $UseCredentials 
                    }
                }
                "AppId" 
                {
                    $appId = $Credential['id']
                    if ($pscmdlet.ShouldProcess("$Url", ("Open with AppId {0} " -f $appId)))
                    {
                        Write-Verbose ("Connect to {0} with AppId {1}" -f $URL, $Credential['id'])
                        Connect-PnPOnline -Url $URL -AppId $Credential['id'] -AppSecret $Credential['secret']
                    }
                }
            }
        } 
        else 
        {
            if ($pscmdlet.ShouldProcess("$Url", "Open with WebLogin"))
            {
                Write-Verbose ("Connect to {0} -UseWebLogin" -f $URL)
                Connect-PnPOnline -Url $URL -UseWebLogin
            }
        }
    }
    End
    {
        Get-SPSite
    }
}