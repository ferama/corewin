$versions = @{
    "coreutils"  = "0.0.30"
    "findutils" = "0.8.0"
    "ripgrep" = "14.1.1"
    "helix" = "25.01.1"
    "wsw" = "0.7.1"
    "doggo" = "1.0.5"
    "jq" = "1.7.1"
    "yq" = "4.45.4"
}

# Where to stage the download / extraction
$WorkDir = Join-Path $PSScriptRoot "..\tmp"
# Final destination for the binary
$BinDir = Join-Path $PSScriptRoot "..\bin"

# ---------------------------------------------------------------------------

# Ensure folders exist
$null = New-Item -ItemType Directory -Force -Path $WorkDir, $BinDir

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
DownloadArtifacts -Url "https://github.com/helix-editor/helix/releases/download/$($versions['helix'])/helix-$($versions['helix'])-x86_64-windows.zip"
DownloadArtifacts -Url "https://github.com/ferama/wsw/releases/download/$($versions['wsw'])/wsw-x86_64.zip"
DownloadArtifacts -Url "https://github.com/mr-karan/doggo/releases/download/v$($versions['doggo'])/doggo_$($versions['doggo'])_Windows_x86_64.zip"

Invoke-WebRequest -Uri https://github.com/jqlang/jq/releases/download/jq-$($versions['jq'])/jq-windows-amd64.exe -OutFile (Join-Path $BinDir "jq.exe")
Invoke-WebRequest -Uri https://github.com/mikefarah/yq/releases/download/v$($versions['yq'])/yq_windows_amd64.exe -OutFile (Join-Path $BinDir "yq.exe")

# # cleanup unwanted
Remove-Item $BinDir/testing-commandline.exe

& "$PSScriptRoot/generate-wxs.ps1"
Remove-Item $WorkDir -Recurse -Force


