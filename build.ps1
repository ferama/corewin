<#
.SYNOPSIS
    Download and install uutils-coreutils v0.0.30 for Windows.

.DESCRIPTION
    • Downloads the ZIP asset for x86-64/MSVC.
    • Extracts it to a temporary working directory.
    • Copies coreutils.exe into a local “bin” directory that you can add to $Env:Path.
#>

# ----- Configuration ---------------------------------------------------------
$Version        = "0.0.30"
$Repo           = "uutils/coreutils"
$Tag            = "$Version"
$AssetFile      = "coreutils-$Version-x86_64-pc-windows-msvc.zip"

# Where to stage the download / extraction
$WorkDir        = Join-Path $PSScriptRoot "coreutils_tmp"
# Final destination for the binary
$BinDir         = Join-Path $PSScriptRoot "bin"

# ---------------------------------------------------------------------------

# Ensure folders exist
$null = New-Item -ItemType Directory -Force -Path $WorkDir, $BinDir

# Construct download URL
$DownloadUrl = "https://github.com/$Repo/releases/download/$Tag/$AssetFile"
$ZipPath     = Join-Path $WorkDir $AssetFile

Write-Host "Downloading $AssetFile ..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

Write-Host "Extracting ..."
Expand-Archive -Path $ZipPath -DestinationPath $WorkDir -Force

# Locate coreutils.exe in extraction tree
$exe = Get-ChildItem -Path $WorkDir -Recurse -Filter "coreutils.exe" |
       Select-Object -First 1

if (-not $exe) {
    throw "coreutils.exe not found after extraction."
}

Write-Host "Copying coreutils.exe to $BinDir ..."
Copy-Item -Path $exe.FullName -Destination (Join-Path $BinDir "coreutils.exe") -Force

# Optional clean-up
Remove-Item $WorkDir -Recurse -Force

Write-Host "coreutils.exe is now in: $BinDir"
Write-Host "   Add that folder to your PATH, e.g.:"
Write-Host '   [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";' + $BinDir + '", "User")'