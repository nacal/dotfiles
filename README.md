# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理している dotfiles。

## 構成

| パス | 内容 |
|------|------|
| `dot_zshrc` | `~/.zshrc` (共通) |
| `encrypted_dot_zshrc.work.zsh.age` | `~/.zshrc.work.zsh` (業務固有 abbr、age 暗号化) |
| `dot_config/wezterm/` | `~/.config/wezterm/` (WezTerm 設定) |
| `dot_claude/` | `~/.claude/` (Claude Code 設定) |
| `Brewfile.tmpl` | `brew bundle` 用 (`~/Brewfile` に展開) |

`dot_zshrc.tmpl` / `Brewfile.tmpl` は OS 分岐するテンプレート (`{{ if eq .chezmoi.os "darwin" }}` 等)。

## 新マシンへのセットアップ

### macOS

```sh
# 1. chezmoi と age をインストール
brew install chezmoi age

# 2. age 秘密鍵を配置 (1Password 等から)
mkdir -p ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 3. chezmoi init で展開 (work machine か聞かれる)
chezmoi init --apply https://github.com/nacal/dotfiles.git

# 4. Brewfile から各種ツールをインストール
brew bundle --file=~/Brewfile
```

### Linux / WSL2

```sh
# 1. age と chezmoi をインストール
sudo apt update && sudo apt install -y age
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. age 秘密鍵を配置
mkdir -p ~/.config/chezmoi
cp /mnt/c/path/to/key.txt ~/.config/chezmoi/key.txt   # WSL2 なら Windows 側から
chmod 600 ~/.config/chezmoi/key.txt

# 3. chezmoi init
~/.local/bin/chezmoi init --apply https://github.com/nacal/dotfiles.git

# 4. (任意) Linuxbrew を入れて Brewfile を実行
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#   brew bundle --file=~/Brewfile
```

## 日常運用

```sh
chezmoi edit ~/.zshrc            # 編集 (source dir のファイルを開く)
chezmoi diff                     # 差分確認
chezmoi apply                    # 適用
chezmoi cd                       # source dir に移動して git 操作

# 業務固有ファイルの編集 (自動で暗号化される)
chezmoi edit ~/.zshrc.work.zsh
```
