Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Create self signed certificate
$certParams = @{
    CertStoreLocation = 'Cert:\LocalMachine\My'
    DnsName           = $env:COMPUTERNAME
    NotAfter          = (Get-Date).AddYears(1)
    Provider          = 'Microsoft Software Key Storage Provider'
    Subject           = "CN=$env:COMPUTERNAME"
}
$cert = New-SelfSignedCertificate @certParams

# Create HTTPS listener
$httpsParams = @{
    ResourceURI = 'winrm/config/listener'
    SelectorSet = @{
        Transport = "HTTPS"
        Address   = "*"
    }
    ValueSet = @{
        CertificateThumbprint = $cert.Thumbprint
        Enabled               = $true
    }
}
New-WSManInstance @httpsParams

#Firewall enable for HTTP and HTTPS
New-NetFirewallRule -Profile Any -Protocol TCP -LocalPort 5986 -Direction Inbound -Action Allow -Description 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]' -DisplayName 'Windows Remote Management (HTTPS-In)'
New-NetFirewallRule -Profile Any -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow -Description 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]' -DisplayName 'Windows Remote Management (HTTP-In)'