Add-Type -AssemblyName System.Drawing

# High-quality compression encoder
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]85)

$images = @("rec_house.png", "cat_house.png", "rec_land.png", "cat_land.png", "rec_farm.png", "cat_farm.png", "rec_apartment.png", "cat_apartment.png", "rec_rental.png", "cat_rental.png")

foreach ($imgName in $images) {
    $filePath = Join-Path "c:\xampp\htdocs\land\assets\images" $imgName
    if (Test-Path $filePath) {
        $img = [System.Drawing.Image]::FromFile($filePath)
        $ms = New-Object System.IO.MemoryStream
        $img.Save($ms, $codec, $encoderParams)
        $bytes = $ms.ToArray()
        $img.Dispose()
        $ms.Dispose()

        # Write back as optimized image
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
        Write-Host "Optimized $imgName : $([math]::Round($bytes.Length / 1KB, 1)) KB" -ForegroundColor Green
    }
}
