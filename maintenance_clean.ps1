

function Show-Menu {
    Clear-Host
    Write-Host "=======Jafar Gans😎=======" -ForegroundColor Cyan
    Write-Host " 🛠️PC Maintenance Menu🛠️"
    Write-Host "===========================" -ForegroundColor Cyan
    Write-Host "1. Cek koneksi jaringan (Ping)"
    Write-Host "2. Cek kesehatan HDD/SSD"
    Write-Host "3. Cek kesehatan Windows (sfc)"
    Write-Host "4. Instal aplikasi via CLI (Scoop)"
    Write-Host "5. Aktivasi Windows/Office"
    Write-Host "0. Keluar"
    Write-Host ""
}

function Install-ScoopIfNeeded {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "🔧 Scoop belum terpasang. Menginstal Scoop sekarang..." -ForegroundColor Cyan
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-WebRequest -Uri "https://github.com/ScoopInstaller/Install/raw/master/install.ps1" -OutFile "$env:TEMP\scoop-install.ps1"
        try {
            powershell -NoProfile -ExecutionPolicy RemoteSigned -File "$env:TEMP\scoop-install.ps1"
            $env:PATH += ";$env:USERPROFILE\scoop\shims"
            Write-Host "✅ Scoop berhasil diinstal." -ForegroundColor Green
        } catch {
            Write-Host "❌ Gagal menginstal Scoop." -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "✅ Scoop sudah terpasang." -ForegroundColor Green
    }
    return $true
}

function Cek-Jaringan {
    Write-Host "`n🔍 Membuka jendela baru untuk ping google.com ..." -ForegroundColor Yellow
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "ping google.com"
}

function Cek-HDD {
    Write-Host "`n💽 Membuka jendela baru untuk cek kesehatan HDD/SSD ..." -ForegroundColor Yellow
    $script = @'
Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus | ForEach-Object {
    $status = if ($_.PredictFailure -eq $true) {"❌ Bermasalah"} else {"✅ Sehat"}
    Write-Host "Drive: $($_.InstanceName) - Status: $status"
}
Get-PhysicalDisk | Format-Table FriendlyName, MediaType, HealthStatus, OperationalStatus, Size
pause
'@
    $tempScript = "$env:TEMP\cek-hdd.ps1"
    $script | Out-File -Encoding UTF8 -FilePath $tempScript
    Start-Process pwsh -ArgumentList "-NoExit", "-ExecutionPolicy Bypass", "-File `"$tempScript`""
}

function Cek-Windows {
    Write-Host "`n🧱 Membuka jendela baru untuk menjalankan 'sfc /scannow' ..." -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "sfc /scannow"
}

function Install-Aplikasi {
    if (-not (Install-ScoopIfNeeded)) {
        Write-Host "❌ Batal instalasi aplikasi karena scoop gagal dipasang." -ForegroundColor Red
        return
    }

    Write-Host "`n📦 Instalasi aplikasi via Scoop" -ForegroundColor Yellow
    Write-Host "1. Google Chrome"
    Write-Host "2. 7zip"
    Write-Host "3. VLC Media Player"
    Write-Host "4. Notepad++"
    Write-Host "5. Git"
    Write-Host "6. Ketik nama aplikasi lain"

    $choice = Read-Host "Pilih nomor atau ketik langsung nama aplikasi"

    $app = switch ($choice) {
        "1" { Read-Host "Search apps" }
        default { $choice }
    }

    if (-not [string]::IsNullOrWhiteSpace($app)) {
        Write-Host "🚀 Menginstal $app di jendela baru..."
        Start-Process pwsh -ArgumentList "-NoExit", "-Command", "scoop install $app"
    } else {
        Write-Host "❌ Nama aplikasi tidak valid." -ForegroundColor Red
    }
}

function Aktivasi-Windows {
    Write-Host "`n🪪 Membuka jendela baru untuk aktivasi Windows..." -ForegroundColor Yellow
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "irm https://get.activated.win | iex"
}

# MENU LOOP
do {
    Show-Menu
    $menu = Read-Host "Pilih opsi (0-5)"
    switch ($menu) {
        "1" { Cek-Jaringan }
        "2" { Cek-HDD }
        "3" { Cek-Windows }
        "4" { Install-Aplikasi }
        "5" { Aktivasi-Windows }
        "0" { Write-Host "👋 Sampai jumpa!" -ForegroundColor Green }
        default { Write-Host "❗ Pilihan tidak valid, coba lagi." -ForegroundColor Red; Pause }
    }
} while ($menu -ne "0")
