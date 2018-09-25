function Decrypt-SecureString {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
        [System.Security.SecureString]
        $sstr
    )

    $marshal = [System.Runtime.InteropServices.Marshal]
    $ptr = $marshal::SecureStringToBSTR( $sstr )
    $str = $marshal::PtrToStringBSTR( $ptr )
    $marshal::ZeroFreeBSTR( $ptr )
    $str
}

function Encrypt-PasswordString {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
        [String]
        $Password
    )
    process{
        $SecureString = convertto-securestring $Password -asplaintext -force
        ConvertFrom-SecureString -SecureString $SecureString
    }
}

function Decrypt-PasswordString {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
        [String]
        $Encrypted
    )
    Process{
        $Secure = ConvertTo-SecureString -String $Encrypted
        Decrypt-SecureString $Secure
    }
}

