# ---- config -------------------------------------------------------------
$extrasDir   = Join-Path $PSScriptRoot '..\bin'      # adjust if needed
$wixDir      = Join-Path $PSScriptRoot '..\wix'
$outFile     = Join-Path $wixDir 'bins.wxs'

# Ensure wix directory exists
if (-not (Test-Path $wixDir)) { New-Item -ItemType Directory -Path $wixDir | Out-Null }

# Collect .exe files
$exeFiles = Get-ChildItem -Path $extrasDir -Filter '*.exe'
if ($exeFiles.Count -eq 0) {
    Write-Warning "No .exe files found in $extrasDir"
    return
}

$xml = [System.Text.StringBuilder]::new()
function append { param($line) $null = $xml.AppendLine($line) }

append '<?xml version="1.0" encoding="UTF-8"?>'
append '<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">'
append '  <Fragment>'
append "    <DirectoryRef Id=""APPLICATIONFOLDER"">"
append "      <Directory Id=""ExtrasDir"" Name=""bin"">"

$componentRefs = @()

foreach ($file in $exeFiles) {
    $name = $file.Name
    $nameNoExt      = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) -replace '-', ''
    $compId    = "${nameNoExt}Component"
    $fileId    = "${nameNoExt}File"

    append "        <Component Id=""$compId"" Guid=""*"">"
    append "          <File Id=""$fileId"" Name=""$name"" Source=""bin\\$name"" />"
    append '        </Component>'

    $componentRefs += $compId
}

append '      </Directory>'
append '    </DirectoryRef>'

append '    <ComponentGroup Id="ExtrasComponents">'
foreach ($compId in $componentRefs) {
    append "      <ComponentRef Id=""$compId"" />"
}
append '    </ComponentGroup>'

append '  </Fragment>'
append '</Wix>'

# Write to disk
$xml.ToString() | Set-Content -Encoding UTF8 $outFile
Write-Host "Generated $outFile with $($exeFiles.Count) file(s)."