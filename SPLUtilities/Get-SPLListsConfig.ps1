<#

        Author:           Gerhard Morgenstein
        Version:          V1.0
        Version History:  

        Purpose:          Share Point Lists Config

#>

function Get-SPLListsConfigPath {
    Resolve-FullPath('SharePointListsConfig.xml')
}

function Open-SPLListsConfig {
    Invoke-Item (Get-SPLListsConfigPath)
}

function Get-SPLListsConfig {
    [CmdletBinding()]
    $Filename = Get-SPLListsConfigPath
    [xml]$doc = New-Object System.Xml.XmlDocument
    if (Test-Path -Path $Filename)
    {
        Write-Verbose ("Load {0}" -f $Filename)
        $null = $doc.Load($Filename)
    }
    else
    {
        Write-Verbose ("Create {0}" -f $Filename)
        $null = $doc.AppendChild($Doc.CreateXmlDeclaration("1.0","UTF-8",$null))
        $root = $doc.AppendChild($doc.CreateElement("SharePointListsConfig"))
        $null = $root.AppendChild($doc.CreateElement("Lists"))
    }
    $doc
}