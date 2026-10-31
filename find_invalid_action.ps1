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
$reader.Close()
$response.Close()

$lines = $content -split "`n"
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "Invalid action") {
        Write-Host "Line $($i+1): $($lines[$i])"
        for ($j = [Math]::Max(0, $i-5); $j -le [Math]::Min($lines.Length-1, $i+5); $j++) {
            Write-Host "  $($j+1): $($lines[$j])"
        }
    }
}
