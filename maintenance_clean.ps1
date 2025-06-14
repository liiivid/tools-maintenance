

function Show-Menu {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "   🛠️  Jfr21(づ￣ 3￣)づ - PC Maintenance Menu"
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "1. Cek koneksi jaringan (Ping)"
    Write-Host "2. Cek kesehatan HDD/SSD"
    Write-Host "3. Cek kesehatan Windows(sfc)"
    Write-Host "4. Instal aplikasi via CLI (winget)"
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
    Start-Process powershell -ArgumentList @(
        '-NoExit',
        '-Command',
        @"
Write-Host '📦 Instalasi Program via Winget' -ForegroundColor Yellow

# Meminta input nama program
\$program = Read-Host 'Masukkan nama program yang ingin dicari'

# Mencari program dan menyimpannya ke variabel
Write-Host "`n📦 Mencari program: \$program" -ForegroundColor Yellow
\$hasil = winget search "\$program"

if (-not \$hasil) {
    Write-Host "❌ Tidak ditemukan hasil untuk: \$program" -ForegroundColor Red
    Pause
    exit
}

# Tampilkan hasil pencarian sebagai tabel dan indeks
\$daftar = \$hasil | Select-String '^\s*\d+\s+\S+.*'
if (-not \$daftar) {
    Write-Host "`n📄 Menampilkan hasil lengkap:" -ForegroundColor Cyan
    \$hasil
    Pause
    exit
}

\$hasil | Format-Table
Write-Host "`nPilih salah satu program berdasarkan ID atau nama lengkap dari daftar di atas." -ForegroundColor Cyan
\$pilihan = Read-Host 'Masukkan ID atau Nama paket untuk diinstal'

if ([string]::IsNullOrWhiteSpace(\$pilihan)) {
    Write-Host "⚠️ Tidak ada input. Proses dibatalkan." -ForegroundColor Red
    Pause
    exit
}

Write-Host "`n🚀 Menginstal: \$pilihan" -ForegroundColor Green
winget install --id "\$pilihan" --exact

Pause
"@
    )
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


