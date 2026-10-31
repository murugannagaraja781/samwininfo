<?php
// FTP Uploader for Navanagari Ads APKs & Admin Files
$ftp_server = "217.21.94.159";
$ftp_user = "u170490412.ads.navanagari.com";
$ftp_pass = "aGreen@2026a";

$conn_id = ftp_connect($ftp_server, 21, 120);
if (!$conn_id) {
    die("Could not connect to $ftp_server\n");
}

if (!@ftp_login($conn_id, $ftp_user, $ftp_pass)) {
    die("Could not log in to $ftp_server\n");
}

ftp_pasv($conn_id, true);
echo "Successfully connected & logged into FTP: $ftp_server\n";

function uploadFile($conn_id, $local_file, $remote_file) {
    if (!file_exists($local_file)) {
        echo "Local file does not exist: $local_file\n";
        return false;
    }
    $size = filesize($local_file);
    echo "Uploading $local_file (" . round($size / 1024 / 1024, 2) . " MB) -> $remote_file ...\n";
    $start = microtime(true);
    
    // Ensure remote directory exists if any
    $parts = explode('/', $remote_file);
    if (count($parts) > 1) {
        array_pop($parts);
        $dir = implode('/', $parts);
        @ftp_mkdir($conn_id, $dir);
    }
    
    if (ftp_put($conn_id, $remote_file, $local_file, FTP_BINARY)) {
        $elapsed = round(microtime(true) - $start, 2);
        echo "SUCCESS: $remote_file uploaded in {$elapsed}s\n";
        return true;
    } else {
        echo "FAILED: could not upload $remote_file\n";
        return false;
    }
}

// Check which files to upload based on CLI arg or default
$target = isset($argv[1]) ? $argv[1] : 'all';

if ($target === 'admin' || $target === 'web' || $target === 'all') {
    uploadFile($conn_id, 'admin/index.html', 'admin/index.html');
    uploadFile($conn_id, 'admin/index.php', 'admin/index.php');
    uploadFile($conn_id, 'admin/js/admin.js', 'admin/js/admin.js');
    uploadFile($conn_id, 'index.html', 'index.html');
}

if ($target === 'user_apk' || $target === 'all') {
    if (file_exists('Ads.apk')) {
        uploadFile($conn_id, 'Ads.apk', 'Ads.apk');
        uploadFile($conn_id, 'TenkasiDreamsLand.apk', 'TenkasiDreamsLand.apk');
    }
}

if ($target === 'admin_apk' || $target === 'all') {
    if (file_exists('AdsAdmin.apk')) {
        uploadFile($conn_id, 'AdsAdmin.apk', 'AdsAdmin.apk');
        uploadFile($conn_id, 'TenkasiDreamsAdmin.apk', 'TenkasiDreamsAdmin.apk');
    }
}

ftp_close($conn_id);
echo "FTP session closed.\n";
