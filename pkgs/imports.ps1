# PSReadLine
Set-PSREadLineOption -PredictionSource History

# Terminal-Icons
Import-Module Terminal-Icons

# Starship
Invoke-Expression (&starship init powershell)

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+t' -PSReadLineChordReverseHistory 'Ctrl+h'

# zoxide 
Invoke-Expression (& { (zoxide init powershell | Out-String) })
# remove cd and replace it by zoxide
Remove-Item alias:cd
Set-Alias -Name cd -Value z
