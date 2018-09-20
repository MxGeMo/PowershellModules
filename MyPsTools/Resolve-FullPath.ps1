<#

        Author:           Gerhard Morgenstein
        Version:          V1.0
        Version History:  

        Purpose:          Expands Path to FullName

#>

function Resolve-FullPath{
    param
    (
        [Parameter(
                Mandatory=$true,
                Position=0,
        ValueFromPipeline=$true)]
        [string] $path
    )
     
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}
