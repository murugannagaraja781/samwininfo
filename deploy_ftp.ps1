# Tenkasi Dreams Land - FTP Deploy Script
# Uploads updated API, Web & Admin files to Hostinger server

$ftpHost = "ftp://ftp.tenkasidreams.com"
$ftpUser = "u764430762.tenkasiupload"
$ftpPass = "MyNewlife@2026"
$remoteRoot = ""  # Root of the FTP account is already /public_html

# List of files to upload (Local relative -> Remote relative)
$files = @(
    @{ Local = "api\properties.php";           Remote = "/api/properties.php" },
    @{ Local = "api\activities.php";           Remote = "/api/activities.php" },
    @{ Local = "api\chat.php";                 Remote = "/api/chat.php" },
    @{ Local = "api\users.php";                Remote = "/api/users.php" },
    @{ Local = "api\config.php";               Remote = "/api/config.php" },
    @{ Local = "api\ping.php";                 Remote = "/api/ping.php" },
    @{ Local = "api\create-order.php";         Remote = "/api/create-order.php" },
    @{ Local = "api\verify-payment.php";       Remote = "/api/verify-payment.php" },
    @{ Local = "api\create_order.php";         Remote = "/api/create_order.php" },
    @{ Local = "api\verify_payment.php";       Remote = "/api/verify_payment.php" },
    @{ Local = "api\.htaccess";                Remote = "/api/.htaccess" },
    @{ Local = "api\stats.php";                Remote = "/api/stats.php" },
    @{ Local = "api\init_db.php";              Remote = "/api/init_db.php" },
    @{ Local = "api\payments.php";             Remote = "/api/payments.php" },
    @{ Local = "api\otp.php";                  Remote = "/api/otp.php" },
    @{ Local = "api\.env";                     Remote = "/api/.env" },
    @{ Local = "api\data\properties.json";     Remote = "/api/data/properties.json" },
    @{ Local = "api\data\activities.json";     Remote = "/api/data/activities.json" },
    @{ Local = "api\data\notifications.json";  Remote = "/api/data/notifications.json" },
    @{ Local = "api\data\payments.json";       Remote = "/api/data/payments.json" },
    @{ Local = "api\data\requirements.json";   Remote = "/api/data/requirements.json" },
    @{ Local = "index.html";                   Remote = "/index.html" },
    @{ Local = "index.php";                    Remote = "/index.php" },
    @{ Local = "privacy.html";                 Remote = "/privacy.html" },
    @{ Local = "terms.html";                   Remote = "/terms.html" },
    @{ Local = "refund.html";                  Remote = "/refund.html" },
    @{ Local = "privacy.php";                  Remote = "/privacy.php" },
    @{ Local = "terms.php";                    Remote = "/terms.php" },
    @{ Local = "refund.php";                   Remote = "/refund.php" },
    @{ Local = ".htaccess";                    Remote = "/.htaccess" },
    @{ Local = "js\app.js";                    Remote = "/js/app.js" },
    @{ Local = "css\style.css";                Remote = "/css/style.css" },
    @{ Local = "admin\index.html";             Remote = "/admin/index.html" },
    @{ Local = "admin\index.php";              Remote = "/admin/index.php" },
    @{ Local = "admin\js\admin.js";            Remote = "/admin/js/admin.js" },
    @{ Local = "admin\css\admin.css";          Remote = "/admin/css/admin.css" }
)

$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
$successCount = 0
$failCount = 0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Tenkasi Dreams Land - FTP Deploy" -ForegroundColor Cyan
Write-Host " Server: $ftpHost" -ForegroundColor Gray
Write-Host " Account: $ftpUser" -ForegroundColor Gray
Write-Host " Target: Hostinger /public_html" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($file in $files) {
    $localPath = Join-Path $PWD $file.Local
    $remoteUri = "$ftpHost$($file.Remote)"
    
    if (-not (Test-Path $localPath)) {
        Write-Host "[SKIP] $($file.Local) - File not found" -ForegroundColor Yellow
        continue
    }
    
    try {
        $ftpRequest = [System.Net.FtpWebRequest]::Create($remoteUri)
        $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $ftpRequest.Credentials = $credentials
        $ftpRequest.UseBinary = $true
        $ftpRequest.UsePassive = $true
        $ftpRequest.EnableSsl = $false
        $ftpRequest.Timeout = 30000
        
        $fileContent = [System.IO.File]::ReadAllBytes($localPath)
        $ftpRequest.ContentLength = $fileContent.Length
        
        $requestStream = $ftpRequest.GetRequestStream()
        $requestStream.Write($fileContent, 0, $fileContent.Length)
        $requestStream.Close()
        
        $response = $ftpRequest.GetResponse()
        $status = $response.StatusDescription
        $response.Close()
        
        Write-Host "[OK] $($file.Local) -> $($file.Remote)" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "[FAIL] $($file.Local) -> $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Upload Complete: $successCount success, $failCount failed" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "========================================" -ForegroundColor Cyan
