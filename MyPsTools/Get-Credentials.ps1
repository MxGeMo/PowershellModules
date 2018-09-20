function Get-Credentials
{
    <#
            .SYNOPSIS 
            Get Credentials from config file
            .DESCRIPTION
            Get Credentials from config file(s) and add it to credential hashtable
            .PARAMETER Names
            name(s) of credential file (without .xml)
            .PARAMETER Path
            path where the credential (.xml) are located 
            .EXAMPLE
            Get-Credentials -verbose -Names mg048388, MyRemoteAccess01 -Path $MySecrets
    #> 
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
    SupportsShouldProcess=$true)]
    [Alias()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true, 
                ValueFromRemainingArguments=$false, 
        Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        #[Alias("Credentials")] 
        [string[]]$Names,

        # Param2 help description
        [Parameter(Position=1)]
        #[ValidateScript({$true})]
        [string]
        $Path="."
    )

    Begin
    {
        #Write-Verbose "Begin"
        $MyCredentials=@{}
    }
    Process
    {
        #Write-Verbose "Process BEGIN"
        $FolderName = (Get-Item -Path $path -ErrorAction SilentlyContinue).FullName
        if ($FolderName)
        {
            Write-Verbose ("FolderName is '{0}'" -f $FolderName ) 
            if ($Names) 
            {
                $Names | ForEach-Object { 
                    $Name     = $_
                    $FilePath = $FolderName + "\" + $Name + ".xml"
                    if (!(Test-Path -Path $FilePath))
                    {
                        Write-Warning ("File '{0}' is not found" -f $FilePath)
                    } 
                    else 
                    {
                        if ($pscmdlet.ShouldProcess($_, 'Load'))
                        {
                            Write-Debug ("Process File '{0}'" -f $FilePath )
                            [xml]$xdoc =  new-object System.Xml.XmlDocument
                            $xdoc.load($FilePath)
                            Write-Verbose ("Name is '{0}'" -f $xdoc.DocumentElement.Name)
                            switch ($xdoc.DocumentElement.Name)
                            {
                                "Credentials" 
                                { 
                                    $MyCredentials[$xdoc.Credentials.URL] = @{
                                        'typ'    = 'User'
                                        'user'   = $xdoc.Credentials.UserName
                                        'secret' = $xdoc.Credentials.Password
                                    }
                                    break
                                }
                                "AppCredentials" 
                                { 
                                    $MyCredentials[$xdoc.AppCredentials.URL] = @{
                                        'typ'    = 'AppId'
                                        'id'     = $xdoc.AppCredentials.AppId
                                        'secret' = $xdoc.AppCredentials.AppSecret
                                    }
                                    break
                                }
                            }              
                        }
                    }
                }
            }
        } 
        else 
        {
            Write-Warning ("Path '{0}' is not a valid location" -f $Path)
        }
        #Write-Verbose "Process END"
    }
    End
    {
        #Write-Verbose "End"
        $MyCredentials
    }
}
