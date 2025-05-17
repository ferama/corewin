# import it into $PROFILE
# 
# . $HOME/abw/abw.ps1

$coreutilsPath = "C:\Users\ferama\abw\bin\coreutils.exe"

$coreutilsList = & $coreutilsPath --list |
         Where-Object { $_.Trim() } |
         ForEach-Object { $_.Trim() }

$extraList = @("curl")
$fullList = & {
    $coreutilsList
    $extraList
}
$excludeList = @("more", "mkdir", "[")

foreach ($cmd in $fullList) {
    if ($excludeList.Contains($cmd)) { continue }

    if (Test-Path Alias:$cmd) {
        # Write-Output "Removing alias '$cmd'"
        Remove-Item Alias:$cmd -Force
    }

    New-Item -path function:\ -name global:$cmd -value {
        & $coreutilsPath $cmd @args
    }.GetNewClosure() | Out-Null

}