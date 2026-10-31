try {
    $seed = Invoke-RestMethod -Uri "https://ads.mithradigitalsolutions.com/api/seed_properties.php" -Method Get -TimeoutSec 20
    Write-Host "Seed Response:" ($seed | ConvertTo-Json -Compress)
} catch {
    Write-Host "Seed Error: $($_.Exception.Message)"
}

try {
    $props = Invoke-RestMethod -Uri "https://ads.mithradigitalsolutions.com/api/properties.php" -Method Get -TimeoutSec 20
    Write-Host "Properties Count: $($props.Count)"
    if ($props.Count -gt 0) {
        Write-Host "Sample Title: $($props[0].title)"
    }
} catch {
    Write-Host "Props Error: $($_.Exception.Message)"
}

try {
    $admin = Invoke-WebRequest -Uri "https://ads.mithradigitalsolutions.com/admin/" -UseBasicParsing -TimeoutSec 20
    Write-Host "Admin Page HTTP Status: $($admin.StatusCode)"
} catch {
    Write-Host "Admin Page Error: $($_.Exception.Message)"
}
