param(
    [string]$ftpTargetHost = "ftp.samwin.info"
)

# ==========================================================
# Deploy SamWin Info to Live Server via FTP
# ==========================================================

$ftpUser = "ftb1@samwin.info"
$ftpPass = "Samwin@2026"
$ftpPort = 21

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Deploying SamWin Info to Live Server" -ForegroundColor Green
Write-Host " Target Host: $ftpTargetHost (Port: $ftpPort)" -ForegroundColor Yellow
Write-Host " FTP Account: $ftpUser" -ForegroundColor Yellow
Write-Host " Database: sa1795ec_samwin (User: sa1795ec_root)" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Cyan

# Remove ftp:// prefix if provided
$cleanHost = $ftpTargetHost -replace "^ftp://", "" -replace "/.*$", ""
$baseFtpUri = "ftp://$cleanHost"

$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

function Ensure-FtpDirectory($remoteDirPath) {
    $parts = $remoteDirPath.Trim('/').Split('/')
    $current = ""
    foreach ($part in $parts) {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }
        $current += "/$part"
        $dirUri = "$baseFtpUri$current"
        try {
            $req = [System.Net.FtpWebRequest]::Create($dirUri)
            $req.Credentials = $credentials
            $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
            $req.UsePassive = $true
            $resp = $req.GetResponse()
            $resp.Close()
        } catch {
            # 550 means directory already exists
        }
    }
}

function Upload-FileToFtp($localRelative, $remoteRelative) {
    $localPath = Join-Path $PSScriptRoot $localRelative
    if (-not (Test-Path $localPath)) {
        Write-Host "[SKIP] $localRelative (Not found locally)" -ForegroundColor Yellow
        return $false
    }

    # Ensure parent remote directory exists
    $remoteDir = [System.IO.Path]::GetDirectoryName($remoteRelative).Replace('\', '/')
    if (-not [string]::IsNullOrWhiteSpace($remoteDir) -and $remoteDir -ne "/") {
        Ensure-FtpDirectory $remoteDir
    }

    $remoteUri = "$baseFtpUri$($remoteRelative.Replace('\', '/'))"
    try {
        $req = [System.Net.FtpWebRequest]::Create($remoteUri)
        $req.Credentials = $credentials
        $req.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $req.UseBinary = $true
        $req.UsePassive = $true
        $req.Timeout = 25000

        $bytes = [System.IO.File]::ReadAllBytes($localPath)
        $req.ContentLength = $bytes.Length

        $stream = $req.GetRequestStream()
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Close()

        $resp = $req.GetResponse()
        $resp.Close()
        Write-Host "[OK] $localRelative -> $remoteRelative" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] $localRelative : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. Gather all files to upload
$filesToUpload = @(
    # Root Web Files
    @{ Local = "index.html";        Remote = "/index.html" },
    @{ Local = "index.php";         Remote = "/index.php" },
    @{ Local = "checkout.php";      Remote = "/checkout.php" },
    @{ Local = "privacy.html";      Remote = "/privacy.html" },
    @{ Local = "terms.html";        Remote = "/terms.html" },
    @{ Local = "refund.html";       Remote = "/refund.html" },
    @{ Local = "privacy.php";       Remote = "/privacy.php" },
    @{ Local = "terms.php";         Remote = "/terms.php" },
    @{ Local = "refund.php";        Remote = "/refund.php" },
    @{ Local = "delete-account.html"; Remote = "/delete-account.html" },
    @{ Local = "robots.txt";        Remote = "/robots.txt" },
    @{ Local = "sitemap.xml";       Remote = "/sitemap.xml" },
    @{ Local = "sitemap.php";       Remote = "/sitemap.php" },
    @{ Local = ".htaccess";         Remote = "/.htaccess" },
    
    # Production Environment files (.env)
    @{ Local = ".env.production";   Remote = "/.env" },
    @{ Local = ".env.production";   Remote = "/api/.env" },

    # Assets & Web Client Scripts
    @{ Local = "js\app.js";         Remote = "/js/app.js" },
    @{ Local = "css\style.css";     Remote = "/css/style.css" },

    # Admin Panel
    @{ Local = "admin\index.html";  Remote = "/admin/index.html" },
    @{ Local = "admin\index.php";   Remote = "/admin/index.php" },
    @{ Local = "admin\js\admin.js"; Remote = "/admin/js/admin.js" },
    @{ Local = "admin\css\admin.css"; Remote = "/admin/css/admin.css" },

    # Core API Backend
    @{ Local = "api\config.php";          Remote = "/api/config.php" },
    @{ Local = "api\auth.php";            Remote = "/api/auth.php" },
    @{ Local = "api\env.php";             Remote = "/api/env.php" },
    @{ Local = "api\app_config.php";      Remote = "/api/app_config.php" },
    @{ Local = "api\categories.php";      Remote = "/api/categories.php" },
    @{ Local = "api\notifications.php";   Remote = "/api/notifications.php" },
    @{ Local = "api\requirements.php";    Remote = "/api/requirements.php" },
    @{ Local = "api\init_db.php";         Remote = "/api/init_db.php" },
    @{ Local = "api\database.sql";        Remote = "/api/database.sql" },
    @{ Local = "api\properties.php";      Remote = "/api/properties.php" },
    @{ Local = "api\activities.php";      Remote = "/api/activities.php" },
    @{ Local = "api\chat.php";            Remote = "/api/chat.php" },
    @{ Local = "api\users.php";           Remote = "/api/users.php" },
    @{ Local = "api\requests.php";        Remote = "/api/requests.php" },
    @{ Local = "api\payments.php";        Remote = "/api/payments.php" },
    @{ Local = "api\create_order.php";    Remote = "/api/create_order.php" },
    @{ Local = "api\verify_payment.php";  Remote = "/api/verify_payment.php" },
    @{ Local = "api\create-order.php";    Remote = "/api/create-order.php" },
    @{ Local = "api\verify-payment.php";  Remote = "/api/verify-payment.php" },
    @{ Local = "api\legal_advice.php";    Remote = "/api/legal_advice.php" },
    @{ Local = "api\otp.php";             Remote = "/api/otp.php" },
    @{ Local = "api\ping.php";            Remote = "/api/ping.php" },
    @{ Local = "api\stats.php";           Remote = "/api/stats.php" },
    @{ Local = "api\events.php";          Remote = "/api/events.php" },
    @{ Local = "api\fcm_service.php";     Remote = "/api/fcm_service.php" },
    @{ Local = "api\seed_properties.php"; Remote = "/api/seed_properties.php" },
    @{ Local = "api\remove_dummy_data.php"; Remote = "/api/remove_dummy_data.php" },
    @{ Local = "api\.htaccess";           Remote = "/api/.htaccess" },
    
    # Initial JSON Data fallback files
    @{ Local = "api\data\properties.json";     Remote = "/api/data/properties.json" },
    @{ Local = "api\data\activities.json";     Remote = "/api/data/activities.json" },
    @{ Local = "api\data\notifications.json";  Remote = "/api/data/notifications.json" },
    @{ Local = "api\data\payments.json";       Remote = "/api/data/payments.json" },
    @{ Local = "api\data\requirements.json";   Remote = "/api/data/requirements.json" }
)

# Dynamically include any remaining files in api directory
if (Test-Path "$PSScriptRoot\api") {
    Get-ChildItem -Path "$PSScriptRoot\api" -File | ForEach-Object {
        $rel = "api\$($_.Name)"
        $rem = "/api/$($_.Name)"
        if ($_.Name -ne ".env" -and -not ($filesToUpload | Where-Object { $_.Local -eq $rel })) {
            $filesToUpload += @{ Local = $rel; Remote = $rem }
        }
    }
}

# Also include branding images from assets/images if existing
if (Test-Path "$PSScriptRoot\assets\images") {
    Get-ChildItem -Path "$PSScriptRoot\assets\images" -File | ForEach-Object {
        $filesToUpload += @{
            Local = "assets\images\$($_.Name)"
            Remote = "/assets/images/$($_.Name)"
        }
    }
}

$okCount = 0
$failCount = 0

Write-Host "Starting upload of $($filesToUpload.Count) files..." -ForegroundColor Cyan

foreach ($item in $filesToUpload) {
    $res = Upload-FileToFtp $item.Local $item.Remote
    if ($res) { $okCount++ } else { $failCount++ }
}

Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Upload Summary:" -ForegroundColor Cyan
Write-Host " Success: $okCount" -ForegroundColor Green
Write-Host " Failed:  $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "=================================================" -ForegroundColor Cyan
