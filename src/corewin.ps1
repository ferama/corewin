# $binDir = "**PATH**"
$binDir = "C:\Program Files\corewin\bin"
$coreutilsPath = "$binDir\coreutils.exe"
$coreWinLocalDir = "$HOME\.corewin"
$env:Path = "$binDir;" + $env:Path

$env:Path = "$coreWinLocalDir;" + $env:Path     # attach to the beginning


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

# Create local dir
New-Item -ItemType Directory -Force -Path $coreWinLocalDir | Out-Null

# Create coreutils links
foreach ($cmd in $coreutilsList) {
    if ($excludeList.Contains($cmd)) { continue }
    New-Item -Path (Join-Path $coreWinLocalDir "$cmd.exe") -ItemType SymbolicLink -Value $coreutilsPath -Force | Out-Null
    
    if ($cmd -eq "ls")  {
        New-Item -path function:\ -name global:$cmd -value {
            & $coreutilsPath $cmd --color  @args
        }.GetNewClosure() | Out-Null    
        continue
    }
}

$aliases.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value
}