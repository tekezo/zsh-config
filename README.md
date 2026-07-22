# zsh-config

## Install

```sh
mkdir -p ~/.local/share
cd ~/.local/share
git clone https://github.com/tekezo/zsh-config.git

[[ ! -f ~/.zshenv ]] && ln -s ~/.local/share/zsh-config/zshenv ~/.zshenv
[[ ! -f ~/.zshrc ]]  && ln -s ~/.local/share/zsh-config/zshrc  ~/.zshrc
```

Optional machine-local settings remain in:

- `~/.config/zsh/private.zshenv.zsh`
- `~/.config/zsh/private.zshrc.zsh`

## Update

Update this repository from anywhere and restart the current zsh with the new
configuration:

```sh
update-zsh-config
```
