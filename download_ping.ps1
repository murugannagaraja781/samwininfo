$ftpHost = "ftp://ftp.tenkasidreams.com/api/ping.php"
$ftpUser = "u764430762.tenkasiupload"
$ftpPass = "MyNewlife@2026"
$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

$ftpRequest = [System.Net.FtpWebRequest]::Create($ftpHost)
$ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
$ftpRequest.Credentials = $credentials
$ftpRequest.UsePassive = $true

$response = $ftpRequest.GetResponse()
$reader = New-Object System.IO.StreamReader($response.GetResponseStream())
Write-Host "Server /api/ping.php:"
Write-Host $reader.ReadToEnd()
$reader.Close()
$response.Close()
