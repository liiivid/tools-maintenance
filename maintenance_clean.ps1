

function Show-Menu {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "   Jafar Gans😎|🛠️PC Maintenance Menu"
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "1. Cek koneksi jaringan (Ping)"
    Write-Host "2. Cek kesehatan HDD/SSD"
    Write-Host "3. Cek kesehatan Windows(sfc)"
    Write-Host "4. Instal aplikasi via CLI (scoop)"
    Write-Host "5. Aktivasi Windows/office"
    Write-Host "0. Keluar"
    Write-Host ""
}

function Cek-Jaringan {
    Write-Host "`n🔍 Mengecek koneksi ke google.com ..." -ForegroundColor Yellow
    Test-Connection google.com -Count 4
    Pause
}

function Cek-HDD {
    Write-Host "`n💽 Mengecek kesehatan HDD/SSD ..." -ForegroundColor Yellow
    Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus | ForEach-Object {
        $status = if ($_.PredictFailure -eq $true) {"❌ Bermasalah"} else {"✅ Sehat"}
        Write-Host "Drive: $_.InstanceName - Status: $status"
    }
    Get-PhysicalDisk | Format-Table FriendlyName, MediaType, HealthStatus, OperationalStatus, Size
    Pause
}

function Cek-Windows {
    Write-Host "`n🧱 Menjalankan System File Checker (sfc /scannow) ..." -ForegroundColor Yellow
    Start-Process -Verb runAs powershell -ArgumentList "sfc /scannow"
    Pause
}

function Install-Aplikasi {
    Write-Host "`n📦 Instalasi aplikasi via Scoop" -ForegroundColor Yellow

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "🔧 Menginstal Scoop dulu..." -ForegroundColor Cyan
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        irm get.scoop.sh | iex
    }

    Write-Host "`nDaftar aplikasi populer:"
    Write-Host "1. Google Chrome"
    Write-Host "2. 7zip"
    Write-Host "3. VLC Media Player"
    Write-Host "4. Notepad++"
    Write-Host "5. Git"
    Write-Host "6. Cari dan install aplikasi lain (ketik nama aplikasi)"

    $choice = Read-Host "Masukkan nomor aplikasi (1-6) atau langsung ketik nama aplikasi untuk instalasi"

    switch ($choice) {
        "1" { scoop install googlechrome }
        "2" { scoop install 7zip }
        "3" { scoop install vlc }
        "4" { scoop install notepadplusplus }
        "5" { scoop install git }
        "6" {
            $app = Read-Host "Masukkan nama aplikasi (contoh: nodejs, vscode, etc)"
            if (-not [string]::IsNullOrWhiteSpace($app)) {
                Write-Host "Mencoba install $app ..."
                scoop install $app
            } else {
                Write-Host "Nama aplikasi kosong, batal install." -ForegroundColor Red
            }
        }
        default {
            # Kalau input bukan nomor 1-6, coba anggap input itu nama aplikasi langsung
            if (-not [string]::IsNullOrWhiteSpace($choice)) {
                Write-Host "Mencoba install $choice ..."
                scoop install $choice
            } else {
                Write-Host "Pilihan tidak valid." -ForegroundColor Red
            }
        }
    }
    Pause
}


function Aktivasi-Windows {
    Write-Host "`n🪪 Menjalankan aktivasi Windows..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
    Pause
}

do {
    Show-Menu
    $menu = Read-Host "Pilih opsi (0-5)"
    switch ($menu) {
        "1" { Cek-Jaringan }
        "2" { Cek-HDD }
        "3" { Cek-Windows }
        "4" { Install-Aplikasi }
        "5" { Aktivasi-Windows }
        "0" { Write-Host "Sampai jumpa!" -ForegroundColor Green }
        default { Write-Host "Pilihan tidak valid, coba lagi." -ForegroundColor Red; Pause }
    }
} while ($menu -ne "0")

