function Set-Credentials {
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$Name,
        [String]$Username,
        [String]$Password,
        [String]$AppId,
        [String]$AppSecret,
        [String]$Domain
    )
    Begin{
        $registryRoot = ("HKCU:\Software\{0}\Credentials" -f $env:UserName)
        $registryPath = ("HKCU:\Software\{0}\Credentials\{1}" -f $env:UserName, $Name)

        if ($Username -and $AppId)
        {
            Write-Error "can't use -Username and -AppId is not possible"
            break
        }
        elseif ($Username)
        {
            $Type = 'User'
        }
        elseif ($AppId) 
        {
            $Type = 'AppId'
        }
        else
        {
            $Type =  (Get-ItemProperty $registryPath -ErrorAction SilentlyContinue).'(Default)'
            switch ($Type)
            {
                'User'            { 
                    if(!$Username) {$Username =  (Get-ItemProperty $registryPath).'ID'}
                    break
                }
                'AppId'            { 
                    if(!$AppId) {$AppId =  (Get-ItemProperty $registryPath).'ID'}
                    break
                }
            }
        }
        if (!$type){
            Write-Error "no valid Type"
            break
        }
        elseif (!($Username -or $AppId))
        {
            Write-Error "no valid Name"
            break
        }
        Write-verbose ("Store {0} for {1} " -f $name, $registryPath)
    }
    Process{    
        if(!(Test-Path $registryPath)) {
            $null = New-Item         -Path $registryRoot  -Name $Name -Value $Type -Force
        } else {
            $null = New-ItemProperty -Path $registryPath -Name '(Default)' -Value $Type -Force -ErrorAction Stop
        }

        if ($Type -eq 'User')
        {
            $null = New-ItemProperty -Path $registryPath -Name ID -Value $Username -Force
            if ($Password) {
                $null = New-ItemProperty -Path $registryPath -Name Secret -Value (Encrypt-PasswordString $Password) -Force
            } else {
                $null = New-ItemProperty -Path $registryPath -Name Secret -Value (ConvertFrom-SecureString -SecureString (Read-Host -AsSecureString -Prompt ('Enter Password for {0}' -f $Username))) -Force
            }
           
        }
        if ($Type -eq 'AppId')
        {
            $null = New-ItemProperty -Path $registryPath -Name ID -Value $AppId -Force
            if ($AppSecret) {
                $null = New-ItemProperty -Path $registryPath -Name Secret -Value (Encrypt-PasswordString $AppSecret) -Force
            } else {
                $null = New-ItemProperty -Path $registryPath -Name Secret -Value (ConvertFrom-SecureString -SecureString (Read-Host -AsSecureString -Prompt ('Enter AppSecret for {0}' -f $AppId))) -Force
            }
        }
        if ($Domain) {
            $null = New-ItemProperty -Path $registryPath -Name Domain -Value $Domain -Force
        }
    }
    End{
        Write-Output ""
    }
}
