$src = "c:\xampp\htdocs\land\build\app\outputs\flutter-apk\app-release.apk"
$dest = "c:\xampp\htdocs\land\TenkasiDreamsLand.apk"

if (Test-Path $src) {
    Copy-Item $src $dest -Force
    $item = Get-Item $dest
    $mb = [Math]::Round($item.Length / 1MB, 2)
    Write-Host "SUCCESS: Copied $dest ($mb MB)"
} else {
    Write-Host "ERROR: Source $src does not exist"
}
