# Where to stage the download / extraction
$WorkDir        = Join-Path $PSScriptRoot "tmp"
# Final destination for the binary
$BinDir         = Join-Path $PSScriptRoot "bin"

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

DownloadArtifacts -Url "https://github.com/uutils/coreutils/releases/download/0.0.30/coreutils-0.0.30-x86_64-pc-windows-msvc.zip"
DownloadArtifacts -Url "https://github.com/uutils/findutils/releases/download/0.8.0/findutils-x86_64-pc-windows-msvc.zip"
DownloadArtifacts -Url "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-pc-windows-msvc.zip"

#DownloadArtifacts -Url "https://github.com/uutils/diffutils/releases/download/v0.4.2/diffutils-x86_64-pc-windows-msvc.zip"

Invoke-WebRequest -Uri https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-windows-amd64.exe -OutFile (Join-Path $BinDir "jq.exe")
Invoke-WebRequest -Uri https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_windows_amd64.exe -OutFile (Join-Path $BinDir "yq.exe")

Remove-Item $WorkDir -Recurse -Force
