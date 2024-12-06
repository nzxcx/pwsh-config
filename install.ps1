<#
.SYNOPSIS
This script installs essential PowerShell modules and tools and configures the PowerShell profile.
.DESCRIPTION
It installs PSReadLine, Terminal-Icons, PSFzf, Starship, zoxide, eza, gum, lazygit, bat, and ripgrep using Scoop.
Additionally, it sets up the PowerShell profile to import configurations from a separate file.
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

# Function to ensure Scoop buckets are available
function Add-ScoopBucket {
  param (
    [string]$BucketName,
    [string]$BucketUrl = ""
  )
  
  Write-Host "Checking Scoop bucket: $BucketName..." -ForegroundColor Cyan
  $buckets = scoop bucket list
  if ($buckets -notcontains $BucketName) {
    try {
      if ($BucketUrl) {
        scoop bucket add $BucketName $BucketUrl
      }
      else {
        scoop bucket add $BucketName
      }
      Write-Host "Added Scoop bucket: $BucketName" -ForegroundColor Green
    }
    catch {
      Write-Host "Failed to add Scoop bucket $BucketName. Error: $_" -ForegroundColor Red
    }
  }
  else {
    Write-Host "Scoop bucket $BucketName is already added." -ForegroundColor Yellow
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
        Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        # Refresh the PATH to include Scoop
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
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

# Function to setup PowerShell profile with config import
function Set-PowerShellProfile {
  param (
    [string]$ConfigPath
  )
  
  # Ensure the config directory exists
  $configDir = Split-Path -Parent $ConfigPath
  if (!(Test-Path -Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "Created config directory at $configDir" -ForegroundColor Green
  }

  # Create the profile file if it doesn't exist
  if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Created PowerShell profile at $PROFILE" -ForegroundColor Green
  }

  # The import line we want to add
  $importLine = '. "$env:USERPROFILE\.config\pwsh-config\config.ps1"'

  # Read existing content
  $content = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue

  # Check if the line already exists to avoid duplicates
  if ($content -notlike "*$importLine*") {
    # Add a comment and the import line
    $newContent = @"
# Import the config from .config/pwsh-config/config.ps1
$importLine
"@
    # If the file is not empty, add a newline before our new content
    if ($content) {
      $newContent = "`n$newContent"
      Add-Content -Path $PROFILE -Value $newContent
    }
    else {
      Set-Content -Path $PROFILE -Value $newContent
    }
    Write-Host "Profile updated successfully with config import." -ForegroundColor Green
  }
  else {
    Write-Host "Profile already contains the config import." -ForegroundColor Yellow
  }

  # Create an empty config file if it doesn't exist
  if (!(Test-Path -Path $ConfigPath)) {
    New-Item -ItemType File -Path $ConfigPath -Force | Out-Null
    Write-Host "Created empty config file at $ConfigPath" -ForegroundColor Green
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

  # Ensure necessary Scoop buckets are added
  Add-ScoopBucket -BucketName "extras"
  Add-ScoopBucket -BucketName "nerd-fonts"

  # Install tools using Scoop
  $tools = @(
    "gum",
    "lazygit",
    "bat",
    "ripgrep",
    "starship",
    "zoxide", 
    "eza" 
  )
  foreach ($tool in $tools) {
    Install-ToolWithScoop -ToolName $tool
  }

  # Setup PowerShell profile with config import
  $configPath = "$env:USERPROFILE\.config\pwsh-config\config.ps1"
  Set-PowerShellProfile -ConfigPath $configPath

  Write-Host "All operations completed successfully." -ForegroundColor Green
  Write-Host @"

"@ -ForegroundColor Cyan
}
catch {
  Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
}
