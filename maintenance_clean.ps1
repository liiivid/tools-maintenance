Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "PC Maintenance Toolkit"
$form.Size = New-Object System.Drawing.Size(400,350)
$form.StartPosition = "CenterScreen"

# Label info
$label = New-Object System.Windows.Forms.Label
$label.Text = "Pilih fungsi maintenance yang ingin dijalankan"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(30,20)
$form.Controls.Add($label)

# Output textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.WordWrap = $true
$outputBox.Size = New-Object System.Drawing.Size(340,150)
$outputBox.Location = New-Object System.Drawing.Point(20,50)
$form.Controls.Add($outputBox)

# Tombol helper untuk run command dan tulis output
function Run-Command($scriptBlock) {
    $outputBox.Clear()
    $ps = [powershell]::Create()
    $ps.AddScript($scriptBlock) | Out-Null
    $ps.AddScript('$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null') | Out-Null
    $ps.Streams.Error.DataAdded += {
        $err = $ps.Streams.Error.ReadAll()
        foreach ($e in $err) {
            $outputBox.AppendText("[ERROR] " + $e.ToString() + "`r`n")
        }
    }
    $ps.BeginInvoke() | Out-Null
}

# Tombol Cek Jaringan
$btnPing = New-Object System.Windows.Forms.Button
$btnPing.Text = "Cek Jaringan (Ping)"
$btnPing.Size = New-Object System.Drawing.Size(160,30)
$btnPing.Location = New-Object System.Drawing.Point(20,220)
$btnPing.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Mengecek koneksi ke google.com ...`r`n")
    $results = Test-Connection google.com -Count 4 | ForEach-Object {
        "Reply from $($_.Address): time=$($_.ResponseTime)ms"
    }
    $results | ForEach-Object { $outputBox.AppendText($_ + "`r`n") }
})
$form.Controls.Add($btnPing)

# Tombol Cek HDD/SSD
$btnHDD = New-Object System.Windows.Forms.Button
$btnHDD.Text = "Cek Kesehatan HDD/SSD"
$btnHDD.Size = New-Object System.Drawing.Size(160,30)
$btnHDD.Location = New-Object System.Drawing.Point(200,220)
$btnHDD.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Mengecek kesehatan HDD/SSD ...`r`n")
    $hddStatus = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus
    foreach ($disk in $hddStatus) {
        $status = if ($disk.PredictFailure) { "⚠️ Bermasalah" } else { "✅ Sehat" }
        $outputBox.AppendText("Drive: $($disk.InstanceName) - Status: $status`r`n")
    }
    $physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, Size
    foreach ($pd in $physicalDisks) {
        $sizeGB = [math]::Round($pd.Size/1GB,2)
        $outputBox.AppendText("Disk: $($pd.FriendlyName), Tipe: $($pd.MediaType), Status: $($pd.HealthStatus), Size: $sizeGB GB`r`n")
    }
})
$form.Controls.Add($btnHDD)

# Tombol Cek Windows (sfc)
$btnSFC = New-Object System.Windows.Forms.Button
$btnSFC.Text = "Cek Integritas Windows (SFC) "
$btnSFC.Size = New-Object System.Drawing.Size(340,30)
$btnSFC.Location = New-Object System.Drawing.Point(20,260)
$btnSFC.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Menjalankan sfc /scannow, ini mungkin butuh waktu ...`r`n")
    Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Verb runAs
})
$form.Controls.Add($btnSFC)

# Tombol Install aplikasi via scoop
$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install Aplikasi via Scoop"
$btnInstall.Size = New-Object System.Drawing.Size(340,30)
$btnInstall.Location = New-Object System.Drawing.Point(20,300)
$btnInstall.Add_Click({
    $outputBox.Clear()
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        $outputBox.AppendText("Scoop belum terpasang. Menginstal Scoop dulu...`r`n")
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        irm get.scoop.sh | iex
        $outputBox.AppendText("Scoop terpasang.`r`n")
    }
    $apps = @("googlechrome", "7zip", "vlc", "notepadplusplus", "git")
    $appNames = @("Google Chrome", "7zip", "VLC Media Player", "Notepad++", "Git")
    $formApps = New-Object System.Windows.Forms.Form
    $formApps.Text = "Pilih Aplikasi untuk Instalasi"
    $formApps.Size = New-Object System.Drawing.Size(300,250)
    $formApps.StartPosition = "CenterParent"

    $checkedList = New-Object System.Windows.Forms.CheckedListBox
    $checkedList.Size = New-Object System.Drawing.Size(260,150)
    $checkedList.Location = New-Object System.Drawing.Point(10,10)
    $appNames | ForEach-Object { $checkedList.Items.Add($_) | Out-Null }
    $formApps.Controls.Add($checkedList)

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "Install"
    $btnOk.Location = New-Object System.Drawing.Point(100,170)
    $btnOk.Size = New-Object System.Drawing.Size(80,30)
    $btnOk.Add_Click({
        $selectedApps = @()
        foreach ($i in $checkedList.CheckedIndices) {
            $selectedApps += $apps[$i]
        }
        $formApps.Close()
        foreach ($app in $selectedApps) {
            $outputBox.AppendText("Menginstall $app ...`r`n")
            scoop install $app
            $outputBox.AppendText("$app selesai diinstall.`r`n")
        }
    })
    $formApps.Controls.Add($btnOk)

    $formApps.ShowDialog() | Out-Null
})
$form.Controls.Add($btnInstall)

# Tombol Aktivasi Windows
$btnActivate = New-Object System.Windows.Forms.Button
$btnActivate.Text = "Aktivasi Windows Otomatis"
$btnActivate.Size = New-Object System.Drawing.Size(340,30)
$btnActivate.Location = New-Object System.Drawing.Point(20,340)
$btnActivate.Add_Click({
    $outputBox.Clear()
    $outputBox.AppendText("Menjalankan aktivasi Windows ...`r`n")
    irm https://get.activated.win | iex
})
$form.Controls.Add($btnActivate)

$form.Height = 420

# Tampilkan form
[void] $form.ShowDialog()
