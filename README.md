# My own powershell configuration for windows

## Contains: 
Aliases, functions and Gum scripts for handling git branches, git conventionnal commits

The script install automatically:
- Scoop
- starship
- zoxide
- eza
- PSReadline
- Terminal-Icons
- PSFzf
- gum
- lazygit
- bat
- ripgrep

## Installation

1. Clone the repository to $env:USERPROFILE\.config\pwsh-config

```ps1
git clone https://github.com/nzxcx/pwsh-config.git $env:USERPROFILE\.config\pwsh-config
```

2. Run the install script

```ps1
& $env:USERPROFILE\.config\pwsh-config\install.ps1
```
