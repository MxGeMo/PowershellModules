function Open-WindowsPowerShell
{
    [CmdletBinding()]
    [Alias()]
    Param([Switch]$code)

    $WindowsPowerShell = (Get-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' -Name Personal).Personal + "\WindowsPowerShell"
    if ($code) {
        code $WindowsPowerShell
    }
    else {
        Invoke-Item $WindowsPowerShell
    }
}