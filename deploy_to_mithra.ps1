# ==========================================================
# Deploy to ads.mithradigitalsolutions.com via FTP
# Server: 145.79.211.112
# Account: u796384200.ads.mithradigitalsolutions.com
# ==========================================================

$ftpHost = "ftp://145.79.211.112"
$ftpUser = "u796384200.ads.mithradigitalsolutions.com"
$ftpPass = "aGreen@2026a"
$credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Starting Deployment to https://ads.mithradigitalsolutions.com" -ForegroundColor Green
Write-Host " FTP Server: $ftpHost" -ForegroundColor Yellow
Write-Host " User: $ftpUser" -ForegroundColor Yellow
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
            Write-Host "[MKDIR] Created $current" -ForegroundColor Cyan
        } catch {
            # Directory might already exist (550), which is normal
        }
    }
}

function Upload-FileToFtp($localRelative, $remoteRelative) {
    $localPath = Join-Path $PSScriptRoot $localRelative
    if (-not (Test-Path $localPath)) {
        Write-Host "[SKIP] $localRelative (Not found locally)" -ForegroundColor Yellow
        return $false
    }

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

        Write-Host "[OK] $localRelative -> $remoteRelative ($($fileBytes.Length) bytes)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] $localRelative -> $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 1. Directories to ensure
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

Write-Host "`n--> Ensuring Remote Directories..." -ForegroundColor Cyan
foreach ($d in $dirs) {
    Ensure-FtpDirectory $d
}

# 2. Build list of files to upload
$filesToUpload = [System.Collections.Generic.List[PSObject]]::new()

# Root web files
$rootFiles = @(
    "index.html", "index.php", ".htaccess", "checkout.php",
    "delete-account.html", "privacy.html", "privacy.php",
    "refund.html", "refund.php", "terms.html", "terms.php"
)
foreach ($rf in $rootFiles) {
    $filesToUpload.Add([PSCustomObject]@{ Local = $rf; Remote = "/$rf" })
}

# CSS & JS
$filesToUpload.Add([PSCustomObject]@{ Local = "css\style.css"; Remote = "/css/style.css" })
$filesToUpload.Add([PSCustomObject]@{ Local = "js\app.js";     Remote = "/js/app.js" })

# Admin Portal
$filesToUpload.Add([PSCustomObject]@{ Local = "admin\index.html";    Remote = "/admin/index.html" })
$filesToUpload.Add([PSCustomObject]@{ Local = "admin\index.php";     Remote = "/admin/index.php" })
$filesToUpload.Add([PSCustomObject]@{ Local = "admin\css\admin.css"; Remote = "/admin/css/admin.css" })
$filesToUpload.Add([PSCustomObject]@{ Local = "admin\js\admin.js";   Remote = "/admin/js/admin.js" })

# Assets & Images
$images = Get-ChildItem -Path (Join-Path $PSScriptRoot "assets\images") -File
foreach ($img in $images) {
    $filesToUpload.Add([PSCustomObject]@{ Local = "assets\images\$($img.Name)"; Remote = "/assets/images/$($img.Name)" })
}

# Backend API Files
$apiFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "api") -File
foreach ($af in $apiFiles) {
    $filesToUpload.Add([PSCustomObject]@{ Local = "api\$($af.Name)"; Remote = "/api/$($af.Name)" })
}

# Fallback Data Files
$dataFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "api\data") -File
foreach ($df in $dataFiles) {
    $filesToUpload.Add([PSCustomObject]@{ Local = "api\data\$($df.Name)"; Remote = "/api/data/$($df.Name)" })
}

Write-Host "`n--> Uploading $($filesToUpload.Count) Files via FTP..." -ForegroundColor Cyan
$success = 0
$fail = 0

foreach ($item in $filesToUpload) {
    $ok = Upload-FileToFtp $item.Local $item.Remote
    if ($ok) { $success++ } else { $fail++ }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host " Upload Summary: $success Success, $fail Failed" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Yellow" })
Write-Host "=================================================" -ForegroundColor Cyan

# Remove default.php if present
try {
    $delReq = [System.Net.FtpWebRequest]::Create("$ftpHost/default.php")
    $delReq.Credentials = $credentials
    $delReq.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
    $delReq.UsePassive = $true
    $delResp = $delReq.GetResponse()
    $delResp.Close()
    Write-Host "[OK] Removed Hostinger placeholder default.php" -ForegroundColor Green
} catch {
    # It might already be gone
}

# 3. Verification & Database Initialization
Write-Host "`n--> Initializing Database via API..." -ForegroundColor Cyan
Start-Sleep -Seconds 2

try {
    $initRes = Invoke-RestMethod -Uri "https://ads.mithradigitalsolutions.com/api/init_db.php" -Method Get -TimeoutSec 30
    Write-Host "[OK] DB Init Response: $($initRes | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "[WARN] DB Init via HTTPS failed: $($_.Exception.Message). Trying HTTP..." -ForegroundColor Yellow
    try {
        $initRes = Invoke-RestMethod -Uri "http://ads.mithradigitalsolutions.com/api/init_db.php" -Method Get -TimeoutSec 30
        Write-Host "[OK] DB Init Response (HTTP): $($initRes | ConvertTo-Json -Compress)" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] DB Init Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n--> Checking API Status..." -ForegroundColor Cyan
try {
    $pingRes = Invoke-RestMethod -Uri "https://ads.mithradigitalsolutions.com/api/ping.php" -Method Get -TimeoutSec 15
    Write-Host "[OK] Ping Response: $($pingRes | ConvertTo-Json -Compress)" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Ping Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n--> Verifying Web Homepage..." -ForegroundColor Cyan
try {
    $webRes = Invoke-WebRequest -Uri "https://ads.mithradigitalsolutions.com/" -UseBasicParsing -TimeoutSec 15
    Write-Host "[OK] Web Homepage HTTP Status: $($webRes.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Web Homepage Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nDeployment Complete!" -ForegroundColor Green
