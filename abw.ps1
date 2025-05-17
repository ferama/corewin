# import it into $PROFILE
# 
# . $HOME/abw/abw.ps1

$binDir = "$HOME\abw\bin"
$coreutilsPath = "$binDir\coreutils.exe"
$env:Path = "$binDir;" + $env:Path


$coreutilsList = & $coreutilsPath --list |
         Where-Object { $_.Trim() } |
         ForEach-Object { $_.Trim() }

# alias will be removed for this lists
$extraList = @("curl")
$fullList = & {
    $coreutilsList
    $extraList
}
$excludeList = @("more", "mkdir", "[")

$createAliases = @{
    "grep"  = "rg"
    "which" = "where.exe"
}

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

$createAliases.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value
}