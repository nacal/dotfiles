# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理している dotfiles。

## 構成

| パス | 内容 |
|------|------|
| `dot_zshrc` | `~/.zshrc` (共通) |
| `encrypted_dot_zshrc.work.zsh.age` | `~/.zshrc.work.zsh` (業務固有 abbr、age 暗号化) |
| `dot_config/wezterm/` | `~/.config/wezterm/` (WezTerm 設定) |
| `dot_claude/` | `~/.claude/` (Claude Code 設定) |
| `Brewfile` | `brew bundle` 用 (deploy 対象外) |

## 新マシンへのセットアップ

```sh
# 1. Homebrew で chezmoi と age をインストール
brew install chezmoi age

# 2. age 秘密鍵を配置 (1Password 等から)
mkdir -p ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 3. chezmoi init で展開 (work machine か聞かれる)
chezmoi init --apply https://github.com/nacal/dotfiles.git

# 4. Brewfile から各種ツールをインストール
brew bundle --file=~/.local/share/chezmoi/Brewfile
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
