# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# prompt
PROMPT='%F{3}%n%  %F{1}%~%f %# '

# zsh-completions
if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi
autoload -U compinit
compinit -u

# zsh-abbr
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

myaliases=(
  "g=git"
  "gb=git branch"
  "gcl=git clone"
  "gct=git commit"
  "gco=git checkout"
  "gcom=git checkout main"
  "gg=git grep"
  "ga=git add"
  "gd=git diff"
  "gl=git log"
  "gfu=git fetch upstream"
  "gfo=git fetch origin"
  "gmod=git merge origin/develop"
  "gmud=git merge upstream/develop"
  "gmom=git merge origin/main"
  "gcm=git commit -m"
  "gph=git push"
  "gpho=git push origin"
  "gphoh=git push origin HEAD"
  "gphu=git push upstream"
  "gphuh=git push upstream HEAD"
  "gpl=git pull"
  "gplo=git pull origin"
  "gplom=git pull origin main"
  "gst=git stash"
  "gsa=git stash apply"
  "gsl=git stash list"
  "gsu=git stash -u"
  "gsp=git stash pop"
  "ya=yarn add"
  "yd=yarn dev"
  "yi=yarn install"
  "ys=yarn start"
  "d=docker"
  "dcm=docker-compose"
  "dcl=docker-compose logs -f"
  "dce=docker-compose exec"
  "k=kubectl"
  "ka=kubectl apply -f"
  "ke=kubectl exec"
  "kl=kubectl logs -f"
  "kg=kubectl get"
  "kx=kubectx"
  "krm=kubectl delete"
  "rezsh=source ~/.zshrc"
  "c=code ."
)

for alias in $myaliases; do
  abbr -S ${alias} > /dev/null
done

# anyenv
eval "$(anyenv init -)"

# rbenv
eval export PATH="/Users/nacal/.rbenv/shims:${PATH}"
export RBENV_SHELL=zsh
source '/opt/homebrew/Cellar/rbenv/1.2.0/libexec/../completions/rbenv.zsh'
command rbenv rehash 2>/dev/null
rbenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(rbenv "sh-$command" "$@")";;
  *)
    command rbenv "$command" "$@";;
  esac
}

# go
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

# peco
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# 同時に起動しているzshの間でhistoryを共有する
setopt share_history

# 同じコマンドをhistoryに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンドをhistoryに残さない
setopt hist_ignore_space

# historyに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

# cd無しでもディレクトリ移動
setopt auto_cd

# コマンドのスペルミスを指摘
setopt correct

# コマンド履歴の入力補完
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# コマンドのシンタックスハイライト
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ファイル名の補間に失敗してもエラーとせずコマンドを起動する
setopt +o nomatch

# path
export PATH="$HOME/.embulk/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export GPG_TTY=$(tty)

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
