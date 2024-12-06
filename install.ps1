<#
.SYNOPSIS
This script installs essential PowerShell modules and tools without configuring them.

.DESCRIPTION
It installs PSReadLine, Terminal-Icons, PSFzf, gum, lazygit, bat, and ripgrep using Scoop.
Configuration is handled in a separate configuration file.
#>

# Function to install a module if it's not already installed
function Install-ModuleWithCheck {
  param (
    [string]$ModuleName
  )
  if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
    Write-Host "Installing $ModuleName..." -ForegroundColor Cyan
    try {
      Install-Module -Name $ModuleName -Force -AllowPrerelease -ErrorAction Stop
      Write-Host "$ModuleName installed successfully." -ForegroundColor Green
    }
    catch {
      Write-Host "Failed to install $ModuleName. Error: $_" -ForegroundColor Red
    }
  }
  else {
    Write-Host "$ModuleName is already installed." -ForegroundColor Yellow
  }
}

# Function to install a tool using Scoop if it's not already installed
function Install-ToolWithScoop {
  param (
    [string]$ToolName
  )
  
  if (-not (Get-Command $ToolName -ErrorAction SilentlyContinue)) {
    Write-Host "Installing $ToolName using Scoop..." -ForegroundColor Cyan
      
    # Check if Scoop is installed; if not, install it
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
      Write-Host "Scoop is not installed. Installing Scoop..." -ForegroundColor Yellow
      try {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
      }
      catch {
        Write-Host "Failed to install Scoop. Error: $_" -ForegroundColor Red
        return
      }
    }
      
    # Install the tool using Scoop
    try {
      scoop install $ToolName
      Write-Host "$ToolName installed successfully." -ForegroundColor Green
    }
    catch {
      Write-Host "Failed to install $ToolName. Error: $_" -ForegroundColor Red
    }
  }
  else {
    Write-Host "$ToolName is already installed." -ForegroundColor Yellow
  }
}

# Function to clone the repository
function Clone-Repository {
  param (
    [string]$RepoUrl,
    [string]$DestPath
  )

  # Check if Git is installed
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Please install Git and try again." -ForegroundColor Red
    return
  }

  # Check if the destination directory already exists
  if (Test-Path $DestPath) {
    Write-Host "Destination directory already exists. Skipping clone operation." -ForegroundColor Yellow
    return
  }

  # Attempt to clone the repository
  try {
    git clone $RepoUrl $DestPath
    Write-Host "Repository cloned successfully to $DestPath" -ForegroundColor Green
  }
  catch {
    Write-Host "Failed to clone repository: $_" -ForegroundColor Red
  }
}

# Main execution block
try {
  # Check for administrator privileges
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  if (-not $isAdmin) {
    Write-Host "Warning: This script may require administrator privileges for some operations." -ForegroundColor Yellow
  }

  # Set execution policy
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

  # Install PowerShell modules
  $modules = @("PSReadLine", "Terminal-Icons", "PSFzf")
  foreach ($module in $modules) {
    Install-ModuleWithCheck -ModuleName $module
  }

  # Install tools using Scoop
  $tools = @("gum", "lazygit", "bat", "ripgrep")
  foreach ($tool in $tools) {
    Install-ToolWithScoop -ToolName $tool
  }

  # Clone configuration repository
  $repoUrl = "https://github.com/nzxcx/pwsh-config.git"
  $destPath = "$env:USERPROFILE\.config\pwsh"
  Clone-Repository -RepoUrl $repoUrl -DestPath $destPath

  # Modify PowerShell profile
  $newProfilePath = "$env:USERPROFILE\.config\pwsh\profile.ps1"
  $content = ". '$newProfilePath'"

  if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
  }

  if (Select-String -Path $PROFILE -Pattern [regex]::Escape($content) -Quiet) {
    Write-Host "Profile already contains the necessary line." -ForegroundColor Yellow
  }
  else {
    Add-Content -Path $PROFILE -Value $content -Force
    Write-Host "Added '$content' to $PROFILE" -ForegroundColor Green
  }

  Write-Host "All operations completed successfully." -ForegroundColor Green
}
catch {
  Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
}
