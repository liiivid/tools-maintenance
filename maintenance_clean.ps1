

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

function Install-ScoopIfNeeded {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Scoop belum terpasang. Menginstal Scoop sekarang..." -ForegroundColor Cyan

        # Pastikan ExecutionPolicy cukup longgar
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        # Install Scoop secara manual dengan Invoke-WebRequest + Expand-Archive
        $scoopDir = "$env:USERPROFILE\scoop"
        if (-not (Test-Path $scoopDir)) {
            New-Item -ItemType Directory -Path $scoopDir -Force | Out-Null
        }

        Write-Host "Mengunduh Scoop installer..."
        Invoke-WebRequest -Uri "https://github.com/ScoopInstaller/Install/raw/master/install.ps1" -OutFile "$env:TEMP\scoop-install.ps1"

        Write-Host "Menjalankan installer Scoop..."
        try {
            powershell -NoProfile -ExecutionPolicy RemoteSigned -File "$env:TEMP\scoop-install.ps1"
            Write-Host "Scoop berhasil diinstal."
        }
        catch {
            Write-Host "Gagal menginstal Scoop. Silakan instal secara manual." -ForegroundColor Red
            return $false
        }

        # Reload environment PATH supaya scoop dikenali dalam sesi ini
        $env:PATH += ";$env:USERPROFILE\scoop\shims"
    }
    else {
        Write-Host "Scoop sudah terpasang." -ForegroundColor Green
    }
    return $true
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

