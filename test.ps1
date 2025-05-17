$coreutils = "C:\Users\ferama\abw\bin\coreutils.exe"


function Abw-Remove-Aliases {
    $utils = & $coreutils --list |
         # Trim empty lines (just in case) and output as strings
         Where-Object { $_.Trim() } |
         ForEach-Object { $_.Trim() }

    # $utils is now a PowerShell array of the available utilities
    # $utils.Count         # show how many
    # $utils[0..9]   
    foreach ($item in $utils) {
        # Write-Output $item
    }
}

Abw-Remove-Aliases

