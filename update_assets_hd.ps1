Add-Type -AssemblyName System.Drawing

$mappings = @(
    @{
        Src = "C:\Users\N\.gemini\antigravity-ide\brain\32cecd69-8953-4de9-a1ff-b897c10ba39a\rec_house_hd_1789939824801.jpg"
        Dests = @("c:\xampp\htdocs\land\assets\images\rec_house.png", "c:\xampp\htdocs\land\assets\images\cat_house.png")
    },
    @{
        Src = "C:\Users\N\.gemini\antigravity-ide\brain\32cecd69-8953-4de9-a1ff-b897c10ba39a\rec_land_hd_1789939843520.jpg"
        Dests = @("c:\xampp\htdocs\land\assets\images\rec_land.png", "c:\xampp\htdocs\land\assets\images\cat_land.png")
    },
    @{
        Src = "C:\Users\N\.gemini\antigravity-ide\brain\32cecd69-8953-4de9-a1ff-b897c10ba39a\rec_farm_hd_1789939860525.jpg"
        Dests = @("c:\xampp\htdocs\land\assets\images\rec_farm.png", "c:\xampp\htdocs\land\assets\images\cat_farm.png")
    },
    @{
        Src = "C:\Users\N\.gemini\antigravity-ide\brain\32cecd69-8953-4de9-a1ff-b897c10ba39a\rec_apartment_hd_1789939879366.jpg"
        Dests = @("c:\xampp\htdocs\land\assets\images\rec_apartment.png", "c:\xampp\htdocs\land\assets\images\cat_apartment.png")
    },
    @{
        Src = "C:\Users\N\.gemini\antigravity-ide\brain\32cecd69-8953-4de9-a1ff-b897c10ba39a\rec_rental_hd_1789939897450.jpg"
        Dests = @("c:\xampp\htdocs\land\assets\images\rec_rental.png", "c:\xampp\htdocs\land\assets\images\cat_rental.png")
    }
)

foreach ($m in $mappings) {
    if (Test-Path $m.Src) {
        $img = [System.Drawing.Image]::FromFile($m.Src)
        foreach ($d in $m.Dests) {
            # Save as PNG
            $img.Save($d, [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Host "Updated $d ($($img.Width)x$($img.Height))" -ForegroundColor Green
        }
        $img.Dispose()
    } else {
        Write-Host "Source not found: $($m.Src)" -ForegroundColor Red
    }
}
