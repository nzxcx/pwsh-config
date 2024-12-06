function glog {
  git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all 
}

# commit all
function GitCommitAll {
  git add .
  git commit -m "$args"
}
Set-Alias -Name gco -Value GitCommitAll

# commit all and push
function CommitAllAndPush {
  git add .
  git commit -m "$args"
  git push
}
Set-Alias -Name gacp -Value CommitAllAndPush

function GitPull {
  git pull $args
}
Set-Alias -Name gpl -Value GitPull

function GitCheckout {
  git checkout $args
}
Set-Alias -Name gck -Value GitCheckout


function GitResetHard {
  git reset --hard
}
Set-Alias -Name grh -Value GitResetHard

function GitSwitch {
  git switch $args
}
Set-Alias -Name gs -Value GitSwitch
