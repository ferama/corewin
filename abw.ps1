# import it into $PROFILE
# 
# . $HOME/abw/abw.ps1

$coreutilsPath = "$HOME\abw\bin\coreutils.exe"

$coreutilsList = & $coreutilsPath --list |
         Where-Object { $_.Trim() } |
         ForEach-Object { $_.Trim() }

$extraList = @("curl")
$fullList = & {
    $coreutilsList
    $extraList
}
$excludeList = @("more", "mkdir", "[")

# Remove aliases
foreach ($cmd in $fullList) {
    if ($excludeList.Contains($cmd)) { continue }

    if (Test-Path Alias:$cmd) {
        Remove-Item Alias:$cmd -Force
    }
}
# Create coreutils aliases
foreach ($cmd in $coreutilsList) {
    if ($excludeList.Contains($cmd)) { continue }

    New-Item -path function:\ -name global:$cmd -value {
        & $coreutilsPath $cmd @args
    }.GetNewClosure() | Out-Null
}