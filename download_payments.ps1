$ftpHost = "ftp://ftp.tenkasidreams.com/api/payments.php"
$ftpUser = "u764430762.tenkasiupload"
$ftpPass = "MyNewlife@2026"
$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

$ftpRequest = [System.Net.FtpWebRequest]::Create($ftpHost)
$ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
$ftpRequest.Credentials = $credentials
$ftpRequest.UsePassive = $true

$response = $ftpRequest.GetResponse()
$reader = New-Object System.IO.StreamReader($response.GetResponseStream())
$content = $reader.ReadToEnd()
Write-Host "Server /api/payments.php Length:" $content.Length
Write-Host "Contains 'create_order':" ($content.Contains("create_order"))
Write-Host "Contains 'rzp_test_TenkasiDreamsKey':" ($content.Contains("rzp_test_TenkasiDreamsKey"))
$reader.Close()
$response.Close()
