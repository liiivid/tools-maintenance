

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

    # Cek apakah dijalankan sebagai Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "❌ Fungsi ini harus dijalankan sebagai Administrator!" -ForegroundColor Red
        return
    }

    # Jalankan sfc secara diam-diam di background
    $job = Start-Job { sfc /scannow > $null }

    # Tampilkan animasi loading selama proses berjalan
    $dots = "."
    while ($job.State -eq "Running") {
        Write-Host -NoNewline "`r⏳ Memindai sistem $dots  "
        Start-Sleep -Milliseconds 500
        $dots += "."
        if ($dots.Length -gt 10) { $dots = "." }
    }

    # Tunggu job selesai dan ambil output log
    Receive-Job $job | Out-Null
    Remove-Job $job

    # Cek hasil dari log CBS
    $logPath = "C:\Windows\Logs\CBS\CBS.log"
    if (Test-Path $logPath) {
        $logTail = Get-Content $logPath -Tail 50 -ErrorAction SilentlyContinue

        if ($logTail -match "cannot repair") {
            Write-Host "`n❌ Ditemukan file sistem yang rusak dan tidak bisa diperbaiki oleh SFC." -ForegroundColor Red
            Write-Host "🔧 Menjalankan DISM untuk perbaikan image sistem..." -ForegroundColor Yellow

            # Jalankan DISM secara langsung
            DISM /Online /Cleanup-Image /RestoreHealth | Out-Null
            Write-Host "`n✅ DISM selesai. Disarankan menjalankan kembali 'sfc /scannow'." -ForegroundColor Green
        }



function Install-Aplikasi {
    Write-Host "📦 Instalasi Program via Winget" -ForegroundColor Yellow

    # Minta input nama program
    $program = Read-Host "Masukkan nama program yang ingin dicari"

    # Cari program
    Write-Host "`n📦 Mencari program: $program" -ForegroundColor Yellow
    $hasil = winget search "$program"

    if (-not $hasil) {
        Write-Host "❌ Tidak ditemukan hasil untuk: $program" -ForegroundColor Red
        return
    }

    # Tampilkan hasil pencarian
    $hasil | Format-Table
    Write-Host "`nMasukkan ID atau nama program yang ingin diinstal dari daftar di atas." -ForegroundColor Cyan
    $pilihan = Read-Host "Masukkan ID atau nama program"

    if ([string]::IsNullOrWhiteSpace($pilihan)) {
        Write-Host "⚠️ Tidak ada input. Proses dibatalkan." -ForegroundColor Red
        return
    }

    Write-Host "`n🚀 Menginstal: $pilihan" -ForegroundColor Green
    winget install --id "$pilihan" --exact

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


