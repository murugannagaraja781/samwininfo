$cred = New-Object System.Net.NetworkCredential('u764430762.tenkasiupload', 'MyNewlife@2026')
$wc = New-Object System.Net.WebClient
$wc.Credentials = $cred
$content = $wc.DownloadString('ftp://ftp.tenkasidreams.com/.htaccess')
Write-Host "Root .htaccess content:"
Write-Host $content
