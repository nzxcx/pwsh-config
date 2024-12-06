# function to check if gum is installed
function Check-Gum {
  if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-Host "gum is not installed. Please install it before using this function." -ForegroundColor Red
    return $false
  }
  return $true
}

function Start-CommitHelper {
  if (-not (Check-Gum)) {
    return
  }
  function Print-InfoBox {
    gum style `
      --foreground 129 --border-foreground 212 --border double `
      --align center --width 50 --margin "1 2" --padding "2 4" `
      'Conventional Commit Helper 🎇'
  }

  Print-InfoBox

  $validTypes = @("fix", "feat", "docs", "style", "refactor", "test", "chore", "revert", "wip")
  $TYPE = gum choose $validTypes

  $SCOPE = gum input --placeholder "scope"

  if ($SCOPE) {
    $SCOPE = "($SCOPE)"
  }

  $SUMMARY = gum input --value "$TYPE$SCOPE`: " --placeholder "Summary of this change"

  if ($validTypes -notcontains $TYPE) {
    Write-Host "Error: Invalid commit type. Please use one of the predefined types." -ForegroundColor Red
    return
  }

  if ($SUMMARY.Length -gt 72) {
    Write-Host "Error: Commit message is too long. Please keep it under 72 characters." -ForegroundColor Red
    return
  }

  $confirmResult = gum confirm "Commit changes?"
  if ($LASTEXITCODE -eq 0) {
    git commit -m "$SUMMARY"
    Write-Host "Changes committed successfully." -ForegroundColor Green
  }
  else {
    Write-Host "Commit cancelled." -ForegroundColor Yellow
  }
}

Set-Alias -Name commit -Value Start-CommitHelper

function Manage-GitBranches {
  if (-not (Check-Gum)) {
    return
  }    
  function Print-InfoBox {
    gum style `
      --foreground 129 --border-foreground 212 --border double `
      --align center --width 50 --margin "1 2" --padding "2 4" `
      'Git Branch Helper 🎇'
  }

  Print-InfoBox
  $action = gum choose "Create Branch" "Switch Branch" "Delete Branch"
  
  switch ($action) {
    "Create Branch" {
      $newBranch = gum input --placeholder "Enter new branch name"
      git checkout -b $newBranch
      if ($LASTEXITCODE -eq 0) {
        gum style --foreground 82 --border normal --padding "1 2" "Branch '$newBranch' created and checked out successfully."
      }
      else {
        gum style --foreground 196 --border normal --padding "1 2" "Failed to create branch '$newBranch'."
      }
    }
    "Switch Branch" {
      gum style --foreground 45 --border normal --padding "1 2" "Pick a branch to switch to:"
      $branches = git branch --format "%(refname:short)"
      $selectedBranch = gum choose $branches
      git checkout $selectedBranch
      if ($LASTEXITCODE -eq 0) {
        gum style --foreground 82 --border normal --padding "1 2" "Switched to branch '$selectedBranch'."
      }
      else {
        gum style --foreground 196 --border normal --padding "1 2" "Failed to switch to branch '$selectedBranch'."
      }
    }
    "Delete Branch" {
      gum style --foreground 45 --border normal --padding "1 2" "Pick a branch to delete:"
      $branches = git branch --format "%(refname:short)"
      $branchToDelete = gum choose $branches
      $currentBranch = git rev-parse --abbrev-ref HEAD
      if ($branchToDelete -eq $currentBranch) {
        gum style --foreground 208 --border normal --padding "1 2" "Cannot delete the current branch. Please switch to another branch first."
      }
      else {
        git branch -d $branchToDelete
        if ($LASTEXITCODE -eq 0) {
          gum style --foreground 82 --border normal --padding "1 2" "Branch '$branchToDelete' deleted successfully."
        }
        else {
          gum style --foreground 196 --border normal --padding "1 2" "Failed to delete branch '$branchToDelete'. It may have unmerged changes."
        }
      }
    }
  }
}


Set-Alias -Name gb -Value Manage-GitBranches

function Watch-ScssFiles {
  # Find all SCSS files in the current directory and subdirectories, excluding those starting with underscore
  $scssFiles = Get-ChildItem -Path . -Filter *.scss -File -Recurse | 
  Where-Object { $_.Name -notlike '_*' } | 
  Select-Object -ExpandProperty FullName

  # Convert full paths to relative paths
  $relativePaths = $scssFiles | ForEach-Object { Resolve-Path $_ -Relative }

  # Check if any SCSS files were found
  if ($relativePaths.Count -eq 0) {
    Write-Host "No SCSS files found (excluding those starting with underscore)." -ForegroundColor Yellow
    return
  }

  # Prepare sass --watch command
  $watchPairs = $relativePaths | ForEach-Object {
    $cssFile = [System.IO.Path]::ChangeExtension($_, "css")
    "$_`:$cssFile"
  }

  $sassCommand = "sass --watch --no-source-map $($watchPairs -join ' ')"

  # Display the command that will be executed
  Write-Host "The following command will be executed:" -ForegroundColor Cyan
  Write-Host $sassCommand -ForegroundColor Green

  # Confirm before starting sass --watch
  $confirm = Read-Host "Do you want to start watching these files? (Y/N)"
  if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    return
  }

  # Execute the sass command
  Write-Host "Starting sass watch process..." -ForegroundColor Cyan
  Invoke-Expression $sassCommand
}
Set-Alias -name sassw -Value Watch-ScssFiles
