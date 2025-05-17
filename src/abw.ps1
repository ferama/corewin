$binDir = "**PATH**"
# $binDir = "C:\Program Files\abw\bin"
$coreutilsPath = "$binDir\coreutils.exe"
$env:Path = "$binDir;" + $env:Path


$coreutilsList = & $coreutilsPath --list |
         Where-Object { $_.Trim() } |
         ForEach-Object { $_.Trim() }

# alias will be removed for this lists
$extraList = @(
    "curl" # prefer curl.exe
)
$fullList = & {
    $coreutilsList
    $extraList
}

# no function will be created for item in this list
$excludeList = @(
    "more", 
    "mkdir", 
    "[",
    "uname" # breaks vscode ssh remote
)

# alias
$aliases = @{
    "grep"  = "rg"
    "which" = "where.exe"
    "dig" = "doggo.exe"
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

    if ($cmd -eq "ls")  {
        New-Item -path function:\ -name global:$cmd -value {
            & $coreutilsPath $cmd --color  @args
        }.GetNewClosure() | Out-Null    
        continue
    }

    New-Item -path function:\ -name global:$cmd -value {
        & $coreutilsPath $cmd @args
    }.GetNewClosure() | Out-Null
}

$aliases.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value
}