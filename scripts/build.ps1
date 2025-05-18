$versions = @{
    "coreutils"  = "0.0.30"
    "findutils" = "0.8.0"
    "ripgrep" = "14.1.1"
    "micro" = "2.0.14"
    "wsw" = "0.7.1"
    "doggo" = "1.0.5"
    "jq" = "1.7.1"
    "yq" = "4.45.4"
    "git" = "2.49.0"
}

# unwanted files to delete
$deleteList = @(
    "bin/testing-commandline.exe"
)

# Where to stage the download / extraction
$WorkDir = Join-Path $PSScriptRoot "..\tmp"
# Final destination for the binary
$AssetsDir = Join-Path $PSScriptRoot "..\assets"
$BinDir = Join-Path $AssetsDir "bin"
$wixDir = Join-Path $PSScriptRoot '..\wix'

# ---------------------------------------------------------------------------

# makes Invoke-WebRequest looooots faster
$ProgressPreference = 'SilentlyContinue'

Remove-Item $AssetsDir -Recurse -Force -ErrorAction SilentlyContinue
# Ensure folders exist
$null = New-Item -ItemType Directory -Force -Path $WorkDir, $AssetsDir, $BinDir

function DownloadGit {
    param (
        [string]$Version
    )
    $Url = "https://github.com/git-for-windows/git/releases/download/v$Version.windows.1/MinGit-$Version-64-bit.zip"

    $ZipPath = Join-Path $WorkDir MinGit-$Version-64-bit.zip
    Write-Host "Downloading $Url ..."
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath

    Write-Host "Extracting ..."
    Expand-Archive -Path $ZipPath -DestinationPath $WorkDir -Force

    Copy-Item -Path $WorkDir\cmd\* -Destination $BinDir 2>$null
    Copy-Item -Recurse -Path $WorkDir\mingw64 -Destination $AssetsDir 2>$null
}

function DownloadArtifacts {
    param (
        [string]$Url
    )

    $AssetFile = [System.IO.Path]::GetFileName($Url)

    # Construct download URL
    $ZipPath = Join-Path $WorkDir $AssetFile

    Write-Host "Downloading $Url ..."
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath

    Write-Host "Extracting ..."
    Expand-Archive -Path $ZipPath -DestinationPath $WorkDir -Force

    # Locate the specified executable in extraction tree
    Get-ChildItem -Path $WorkDir -Recurse -Filter *.exe |
        ForEach-Object { 
            $ExecutableName = $_.Name
            Write-Host "Copying $ExecutableName to $BinDir ..."

            Copy-Item -Path $_.FullName -Destination (Join-Path $BinDir $ExecutableName) -Force
        }
}

DownloadArtifacts -Url "https://github.com/uutils/coreutils/releases/download/$($versions['coreutils'])/coreutils-$($versions['coreutils'])-x86_64-pc-windows-msvc.zip"
DownloadArtifacts -Url "https://github.com/uutils/findutils/releases/download/$($versions['findutils'])/findutils-x86_64-pc-windows-msvc.zip"
DownloadArtifacts -Url "https://github.com/BurntSushi/ripgrep/releases/download/$($versions['ripgrep'])/ripgrep-$($versions['ripgrep'])-x86_64-pc-windows-msvc.zip"
DownloadArtifacts -Url "https://github.com/ferama/wsw/releases/download/$($versions['wsw'])/wsw-x86_64.zip"
DownloadArtifacts -Url "https://github.com/mr-karan/doggo/releases/download/v$($versions['doggo'])/doggo_$($versions['doggo'])_Windows_x86_64.zip"
DownloadArtifacts -Url "https://github.com/zyedidia/micro/releases/download/v$($versions['micro'])/micro-$($versions['micro'])-win64.zip"

Invoke-WebRequest -Uri https://github.com/jqlang/jq/releases/download/jq-$($versions['jq'])/jq-windows-amd64.exe -OutFile (Join-Path $BinDir "jq.exe")
Invoke-WebRequest -Uri https://github.com/mikefarah/yq/releases/download/v$($versions['yq'])/yq_windows_amd64.exe -OutFile (Join-Path $BinDir "yq.exe")

DownloadGit -Version $versions['git']

# cleanup unwanted
foreach ($item in $deleteList) {
    Remove-Item (Join-Path $AssetsDir $item)
}

# heat is included in wix toolsets
& heat dir $AssetsDir -cg ExtrasComponents -dr APPLICATIONFOLDER -srd -sreg -gg -out $wixDir\bins.wxs

# Fix the SourceDir to assets
(Get-Content $wixDir\bins.wxs) | ForEach-Object {
        $_ -replace "SourceDir", "assets"

} | Set-Content $wixDir\bins.wxs -Encoding UTF8

# Remove the temp directory
Remove-Item $WorkDir -Recurse -Force