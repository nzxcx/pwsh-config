
function Show-EzaListing {
  eza -la --icons --git --color=always --group-directories-first $args
}
Set-Alias -Name ls -Value Show-EzaListing

function clip {
  Get-Content $args | Set-Clipboard 
}

function ls { eza -a }
function ld { eza -lD }
function lf { eza -lF }


function find-file($name) { 
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Output "${place_path}\${_}"
  }
}

function op {
  explorer .
}

function set-title([string]$newtitle) {
  $host.ui.RawUI.WindowTitle = $newtitle + ' – ' + $host.ui.RawUI.WindowTitle
}

function get-path {
  ($Env:Path).Split(";")
}

# Directory navigation functions
function Go-ParentDirectory { Set-Location .. }
Set-Alias -Name '..' -Value Go-ParentDirectory
function Go-GrandparentDirectory { Set-Location ../.. }
Set-Alias -Name '...' -Value Go-GrandparentDirectory
function Go-GreatGrandparentDirectory { Set-Location ../../.. }
Set-Alias -Name '....' -Value Go-GreatGrandparentDirectory
function Go-GreatGreatGrandparentDirectory { Set-Location ../../../.. }
Set-Alias -Name '.....' -Value Go-GreatGreatGrandparentDirectory

