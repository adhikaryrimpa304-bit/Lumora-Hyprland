# Lumora theme for Windows 10/11. Run as your normal user (not admin):
#   powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
# Your previous settings are saved to %APPDATA%\Lumora\backup.json (uninstall.ps1 restores them).
$ErrorActionPreference = 'Stop'

$pers  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$dwm   = 'HKCU:\Software\Microsoft\Windows\DWM'
$acc   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent'
$adv   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$desk  = 'HKCU:\Control Panel\Desktop'

# What we change: path, name, new value (DWord colors are ABGR: primary purple #B026FF, muted purple #6B2FB0)
$changes = @(
    @($pers, 'AppsUseLightTheme',     0),
    @($pers, 'SystemUsesLightTheme',  0),
    @($pers, 'EnableTransparency',    1),
    @($pers, 'ColorPrevalence',       0),
    @($dwm,  'ColorPrevalence',       1),
    @($dwm,  'AccentColor',           [int]0xFFFF26B0),
    @($dwm,  'AccentColorInactive',   [int]0xFFB02F6B),
    @($acc,  'AccentColorMenu',       [int]0xFFFF26B0),
    @($adv,  'TaskbarAl',             1)
)

# ---- Backup ----
$backupDir = Join-Path $env:APPDATA 'Lumora'
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$backupFile = Join-Path $backupDir 'backup.json'
if (-not (Test-Path $backupFile)) {
    $saved = @()
    foreach ($c in $changes) {
        $val = $null
        try { $val = (Get-ItemProperty -Path $c[0] -Name $c[1] -ErrorAction Stop).($c[1]) } catch {}
        $saved += [pscustomobject]@{ Path = $c[0]; Name = $c[1]; Value = $val }
    }
    $oldWall = (Get-ItemProperty $desk).Wallpaper
    @{ Settings = $saved; Wallpaper = $oldWall } | ConvertTo-Json -Depth 4 | Set-Content $backupFile
}

# ---- Apply colors and mode ----
foreach ($c in $changes) {
    if (-not (Test-Path $c[0])) { New-Item -Path $c[0] -Force | Out-Null }
    New-ItemProperty -Path $c[0] -Name $c[1] -Value $c[2] -PropertyType DWord -Force | Out-Null
}

# ---- Wallpaper ----
$src = Join-Path $PSScriptRoot '..\assets\lumora-wallpaper.png'
$picDir = Join-Path $env:USERPROFILE 'Pictures'
$wall = Join-Path $picDir 'lumora-wallpaper.png'
Copy-Item $src $wall -Force
Copy-Item (Join-Path $PSScriptRoot '..\assets\lumora-lock.png') (Join-Path $picDir 'lumora-lock.png') -Force
Copy-Item (Join-Path $PSScriptRoot '..\assets\logo\logo-full.png') (Join-Path $picDir 'lumora-logo.png') -Force
Add-Type @"
using System.Runtime.InteropServices;
public class LumoraWall {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int a, int b, string c, int d);
}
"@
Set-ItemProperty $desk -Name WallpaperStyle -Value '10'
Set-ItemProperty $desk -Name TileWallpaper -Value '0'
[LumoraWall]::SystemParametersInfo(20, 0, $wall, 3) | Out-Null

# ---- Wallpaper pack ----
$packDir = Join-Path $picDir 'Lumora Wallpapers'
New-Item -ItemType Directory -Path $packDir -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-aurora.jpg'),
          (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-horizon.jpg'),
          (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-prism.jpg'),
          (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-nebula.jpg'),
          (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-midnight.jpg'),
          (Join-Path $PSScriptRoot '..\assets\wallpapers\lumora-logo.jpg') $packDir -Force

# ---- Windows Terminal color scheme (cyan and violet) ----
$fragDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\Lumora'
New-Item -ItemType Directory -Path $fragDir -Force | Out-Null
$scheme = @'
{
  "schemes": [
    {
      "name": "Lumora",
      "background": "#130B20", "foreground": "#F1E9FF",
      "cursorColor": "#00F0FF", "selectionBackground": "#B026FF",
      "black": "#1C1230", "red": "#FF5C8A", "green": "#5CFFB1", "yellow": "#FFD166",
      "blue": "#9D6BFF", "purple": "#B026FF", "cyan": "#00F0FF", "white": "#D8C8F5",
      "brightBlack": "#3A2A63", "brightRed": "#FF8FAF", "brightGreen": "#8CFFD0", "brightYellow": "#FFE08F",
      "brightBlue": "#BE9BFF", "brightPurple": "#D26BFF", "brightCyan": "#7DF7FF", "brightWhite": "#FFFFFF"
    }
  ]
}
'@
Set-Content -Path (Join-Path $fragDir 'lumora.json') -Value $scheme -Encoding UTF8

# ---- Clock (Rainmeter) ----
function Find-Rainmeter {
    @("$env:ProgramFiles\Rainmeter\Rainmeter.exe", "${env:ProgramFiles(x86)}\Rainmeter\Rainmeter.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}
$rm = Find-Rainmeter
if (-not $rm) {
    Write-Host 'Installing Rainmeter...'
    winget install --id Rainmeter.Rainmeter -e --accept-source-agreements --accept-package-agreements
    $rm = Find-Rainmeter
}
if ($rm) {
    $skinDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\Lumora\Clock'
    New-Item -ItemType Directory -Path $skinDir -Force | Out-Null
    $ini = Get-Content (Join-Path $PSScriptRoot 'Clock.ini') -Raw
    Set-Content -Path (Join-Path $skinDir 'Clock.ini') -Value $ini -Encoding Unicode
    Start-Process $rm
    Start-Sleep -Seconds 4
    & $rm '!RefreshApp'
    Start-Sleep -Seconds 2
    & $rm '!ActivateConfig' 'Lumora\Clock' 'Clock.ini'
    Add-Type -AssemblyName System.Windows.Forms
    $x = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width - 300
    & $rm '!Move' "$x" '80' 'Lumora\Clock'
    & $rm '!ZPos' '-2' 'Lumora\Clock'
} else {
    Write-Host 'Rainmeter could not be installed. Get it from rainmeter.net and run this script again for the clock.'
}

Stop-Process -Name explorer -Force
Write-Host "Wallpaper pack: $packDir. Terminal: Windows Terminal > Settings > Appearance > Color scheme > Lumora."
Write-Host "Lock screen: Settings > Personalization > Lock screen > Picture > Browse > $picDir\lumora-lock.png"
Write-Host 'Done. Sign out and back in if anything looks unchanged.'
