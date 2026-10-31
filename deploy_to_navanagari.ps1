# ==========================================================
# Deploy to ads.navanagari.com via FTP
# Server: 217.21.94.159
# Account: u170490412.ads.navanagari.com
# ==========================================================

$ftpHost = "ftp://217.21.94.159"
$ftpUser = "u170490412.ads.navanagari.com"
$ftpPass = "aGreen@2026a"
$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Starting Deployment to https://ads.navanagari.com" -ForegroundColor Green
Write-Host " FTP Server: $ftpHost" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Cyan

function Ensure-FtpDirectory($remoteDirPath) {
    $parts = $remoteDirPath.Trim('/').Split('/')
    $current = ""
    foreach ($part in $parts) {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }
        $current += "/$part"
        $dirUri = "$ftpHost$current"
        try {
            $req = [System.Net.FtpWebRequest]::Create($dirUri)
            $req.Credentials = $credentials
            $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
            $req.UsePassive = $true
            $resp = $req.GetResponse()
            $resp.Close()
        } catch {
            # Directory might already exist (550), which is completely fine
        }
    }
}

function Upload-FileToFtp($localRelative, $remoteRelative) {
    $localPath = Join-Path $PSScriptRoot $localRelative
    if (-not (Test-Path $localPath)) {
        Write-Host "[SKIP] $localRelative (Not found locally)" -ForegroundColor Yellow
        return $false
    }

    # Ensure parent remote folder exists
    $remoteFolder = [System.IO.Path]::GetDirectoryName($remoteRelative).Replace('\', '/')
    if (-not [string]::IsNullOrWhiteSpace($remoteFolder) -and $remoteFolder -ne "/") {
        Ensure-FtpDirectory $remoteFolder
    }

    $remoteUri = "$ftpHost$remoteRelative"
    try {
        $req = [System.Net.FtpWebRequest]::Create($remoteUri)
        $req.Credentials = $credentials
        $req.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $req.UseBinary = $true
        $req.UsePassive = $true
        $req.Timeout = 60000
        $req.ReadWriteTimeout = 60000

        $fileBytes = [System.IO.File]::ReadAllBytes($localPath)
        $req.ContentLength = $fileBytes.Length

        $stream = $req.GetRequestStream()
        $stream.Write($fileBytes, 0, $fileBytes.Length)
        $stream.Close()

        $resp = $req.GetResponse()
        $resp.Close()

        Write-Host "[OK] $localRelative -> $remoteRelative" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] $localRelative -> $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Directories to ensure
$dirs = @(
    "/css",
    "/js",
    "/assets",
    "/assets/images",
    "/admin",
    "/admin/css",
    "/admin/js",
    "/api",
    "/api/data",
    "/api/uploads",
    "/api/uploads/props"
)

foreach ($d in $dirs) {
    Ensure-FtpDirectory $d
}

$filesToUpload = @(
    # 1. Root Web Files
    @{ Local = "index.html";          Remote = "/index.html" },
    @{ Local = "index.php";           Remote = "/index.php" },
    @{ Local = ".htaccess";           Remote = "/.htaccess" },
    @{ Local = "checkout.php";        Remote = "/checkout.php" },
    @{ Local = "delete-account.html"; Remote = "/delete-account.html" },
    @{ Local = "privacy.html";        Remote = "/privacy.html" },
    @{ Local = "privacy.php";         Remote = "/privacy.php" },
    @{ Local = "refund.html";         Remote = "/refund.html" },
    @{ Local = "refund.php";          Remote = "/refund.php" },
    @{ Local = "terms.html";          Remote = "/terms.html" },
    @{ Local = "terms.php";           Remote = "/terms.php" },

    # 2. CSS & JS
    @{ Local = "css\style.css";       Remote = "/css/style.css" },
    @{ Local = "js\app.js";           Remote = "/js/app.js" },

    # 3. Assets & Images
    @{ Local = "assets\images\admin_app_logo.png";          Remote = "/assets/images/admin_app_logo.png" },
    @{ Local = "assets\images\admin_ui_sample.jpg";         Remote = "/assets/images/admin_ui_sample.jpg" },
    @{ Local = "assets\images\app_logo.png";                Remote = "/assets/images/app_logo.png" },
    @{ Local = "assets\images\cat_apartment.png";           Remote = "/assets/images/cat_apartment.png" },
    @{ Local = "assets\images\cat_farm.png";                Remote = "/assets/images/cat_farm.png" },
    @{ Local = "assets\images\cat_house.png";               Remote = "/assets/images/cat_house.png" },
    @{ Local = "assets\images\cat_land.png";                Remote = "/assets/images/cat_land.png" },
    @{ Local = "assets\images\cat_legal.png";               Remote = "/assets/images/cat_legal.png" },
    @{ Local = "assets\images\cat_rental.png";              Remote = "/assets/images/cat_rental.png" },
    @{ Local = "assets\images\cat_shop.png";                Remote = "/assets/images/cat_shop.png" },
    @{ Local = "assets\images\hero_banner.png";             Remote = "/assets/images/hero_banner.png" },
    @{ Local = "assets\images\logo.png";                    Remote = "/assets/images/logo.png" },
    @{ Local = "assets\images\rec_apartment.png";           Remote = "/assets/images/rec_apartment.png" },
    @{ Local = "assets\images\rec_farm.png";                Remote = "/assets/images/rec_farm.png" },
    @{ Local = "assets\images\rec_house.png";               Remote = "/assets/images/rec_house.png" },
    @{ Local = "assets\images\rec_land.png";                Remote = "/assets/images/rec_land.png" },
    @{ Local = "assets\images\rec_rental.png";              Remote = "/assets/images/rec_rental.png" },

    # 4. Admin Portal
    @{ Local = "admin\index.html";    Remote = "/admin/index.html" },
    @{ Local = "admin\index.php";     Remote = "/admin/index.php" },
    @{ Local = "admin\css\admin.css"; Remote = "/admin/css/admin.css" },
    @{ Local = "admin\js\admin.js";   Remote = "/admin/js/admin.js" },

    # 5. Backend API Endpoints & Config
    @{ Local = "api\.htaccess";       Remote = "/api/.htaccess" },
    @{ Local = "api\.env";            Remote = "/api/.env" },
    @{ Local = "api\config.php";      Remote = "/api/config.php" },
    @{ Local = "api\ping.php";        Remote = "/api/ping.php" },
    @{ Local = "api\properties.php";  Remote = "/api/properties.php" },
    @{ Local = "api\activities.php";  Remote = "/api/activities.php" },
    @{ Local = "api\chat.php";        Remote = "/api/chat.php" },
    @{ Local = "api\users.php";       Remote = "/api/users.php" },
    @{ Local = "api\create-order.php";   Remote = "/api/create-order.php" },
    @{ Local = "api\create_order.php";   Remote = "/api/create_order.php" },
    @{ Local = "api\verify-payment.php"; Remote = "/api/verify-payment.php" },
    @{ Local = "api\verify_payment.php"; Remote = "/api/verify_payment.php" },
    @{ Local = "api\payments.php";    Remote = "/api/payments.php" },
    @{ Local = "api\stats.php";       Remote = "/api/stats.php" },
    @{ Local = "api\init_db.php";     Remote = "/api/init_db.php" },
    @{ Local = "api\events.php";      Remote = "/api/events.php" },
    @{ Local = "api\fcm_service.php"; Remote = "/api/fcm_service.php" },
    @{ Local = "api\notifications.php"; Remote = "/api/notifications.php" },
    @{ Local = "api\requests.php";    Remote = "/api/requests.php" },
    @{ Local = "api\requirements.php"; Remote = "/api/requirements.php" },
    @{ Local = "api\categories.php";  Remote = "/api/categories.php" },
    @{ Local = "api\auth.php";        Remote = "/api/auth.php" },
    @{ Local = "api\otp.php";         Remote = "/api/otp.php" },
    @{ Local = "api\app_config.php";  Remote = "/api/app_config.php" },
    @{ Local = "api\env.php";         Remote = "/api/env.php" },
    @{ Local = "api\seed_properties.php"; Remote = "/api/seed_properties.php" },
    @{ Local = "api\remove_dummy_data.php"; Remote = "/api/remove_dummy_data.php" },
    @{ Local = "api\opcache_clear.php"; Remote = "/api/opcache_clear.php" },
    @{ Local = "api\database.sql";    Remote = "/api/database.sql" },

    # 6. Fallback Storage Data
    @{ Local = "api\data\properties.json";     Remote = "/api/data/properties.json" },
    @{ Local = "api\data\activities.json";     Remote = "/api/data/activities.json" },
    @{ Local = "api\data\chats.json";          Remote = "/api/data/chats.json" },
    @{ Local = "api\data\live_users.json";     Remote = "/api/data/live_users.json" },
    @{ Local = "api\data\notifications.json";  Remote = "/api/data/notifications.json" },
    @{ Local = "api\data\payments.json";       Remote = "/api/data/payments.json" },
    @{ Local = "api\data\requirements.json";   Remote = "/api/data/requirements.json" },
    @{ Local = "api\data\realtime_events.json"; Remote = "/api/data/realtime_events.json" }
)

$success = 0
$fail = 0

foreach ($item in $filesToUpload) {
    $ok = Upload-FileToFtp $item.Local $item.Remote
    if ($ok) { $success++ } else { $fail++ }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host " Upload Summary: $success Success, $fail Failed" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Yellow" })
Write-Host "=================================================" -ForegroundColor Cyan

# Remove default.php if still present on remote
try {
    $delReq = [System.Net.FtpWebRequest]::Create("$ftpHost/default.php")
    $delReq.Credentials = $credentials
    $delReq.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $delReq.UsePassive = $true
    $delResp = $delReq.GetResponse()
    $delResp.Close()
    Write-Host "[OK] Removed Hostinger default.php" -ForegroundColor Green
} catch {
    # It might already be gone
}
