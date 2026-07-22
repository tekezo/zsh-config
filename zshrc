#
# Language
#

# LANG must use a UTF-8 locale; otherwise, commands such as ls may display
# non-ASCII filenames, including Japanese filenames, as question marks.
export LANG="en_US.UTF-8"

# Do not set LC_ALL here. LC_ALL would override LC_COLLATE and all other
# LC_* variables. Leaving it unset allows the remaining locale categories
# to fall back to LANG.
# export LC_ALL="en_US.UTF-8"

# Use bytewise collation so that commands such as sort and uniq distinguish
# strings with different byte sequences correctly. Some UTF-8 locales may
# otherwise treat distinct Japanese strings as equivalent for collation.
export LC_COLLATE="C"

# Override LC_CTYPE because it may be set to `UTF-8`.
export LC_CTYLE="en_US.UTF-8"

#
# zsh configuration
#

autoload -Uz add-zsh-hook compinit

# Shell and history behavior.
setopt CLOBBER HIST_FCNTL_LOCK INC_APPEND_HISTORY HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS HIST_VERIFY
setopt INTERACTIVE_COMMENTS COMPLETE_IN_WORD ALWAYS_TO_END AUTO_MENU AUTO_LIST
setopt AUTO_PARAM_SLASH
unsetopt AUTO_CD CDABLE_VARS CORRECT EXTENDED_HISTORY MENU_COMPLETE FLOW_CONTROL

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Completion using zsh's built-in completion functions only.
typeset _zcompdump=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
mkdir -p "${_zcompdump:h}"
compinit -i -d "$_zcompdump"
unset _zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'

# Emacs editing and prefix-aware history search without an external plugin.
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^U' backward-kill-line

#
# Other configurations
#

function path-append() {
  local directory
  for directory in "$@"; do
    [[ -d "$directory" && ":$PATH:" != *":$directory:"* ]] &&
      PATH="${PATH:+$PATH:}$directory"
  done
}

function path-prepend() {
  local directory
  for directory in "$@"; do
    [[ -d "$directory" && ":$PATH:" != *":$directory:"* ]] &&
      PATH="$directory${PATH:+:$PATH}"
  done
}

if [[ $(uname) == Linux ]]; then
  alias ls='ls -F --color=auto'
else
  alias ls='ls -FG'
fi

export WORDCHARS=''
export EDITOR=vi VISUAL=vi
export LESS='-i -M -R -X -z-4'
export BC_ENV_ARGS=-l

path-prepend "$HOME/opt/bin"
path-append /usr/sbin /sbin
export GOPATH="$HOME/opt/go"
path-prepend "$GOPATH/bin" "$HOME/opt/node/bin"
export GEM_HOME="$HOME/opt/ruby/gems"
path-prepend "$GEM_HOME/bin"
export COMPOSER_HOME="$HOME/opt/php/composer"
path-prepend "$HOME/opt/php/bin" "$COMPOSER_HOME/vendor/bin"
export PYTHONUSERBASE="$HOME/opt/python"
path-prepend "$PYTHONUSERBASE/bin"
export PATH

function my-widget-set-window-title() {
  print -Pn '\e]2;%20>...>${ZSH_PROMPT_HOSTNAME:-%M} %25<...<%d\a'
}
add-zsh-hook chpwd my-widget-set-window-title
add-zsh-hook precmd my-widget-set-window-title

function my-widget-cdup() { cd ..; zle reset-prompt }
zle -N my-widget-cdup
bindkey '^Q' my-widget-cdup

function my-widget-popd() { popd; zle reset-prompt }
zle -N my-widget-popd
bindkey '^O' my-widget-popd

function my-widget-peco-select-history() {
  local reverse_command=tac
  (( $+commands[tac] )) || reverse_command='tail -r'
  BUFFER=$(fc -l -n 1 | eval "$reverse_command" | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle -R -c
}
zle -N my-widget-peco-select-history
bindkey '^R' my-widget-peco-select-history

function tmux-auto() {
  if tmux list-sessions 2>/dev/null | grep -q '^0:'; then
    tmux attach
  else
    tmux
  fi
}

#
# Create ~/.config/zsh
#

() {
  local private_zsh_dir="$HOME/.config/zsh"
  mkdir -p "$private_zsh_dir"

  if [[ ! -e "$private_zsh_dir/private.zshenv.zsh" ]]; then
    print -r -- '# blue
# export ZSH_PROMPT_SSH_COLOR='"'"'%F{black}%K{blue}'"'"'

# red
# export ZSH_PROMPT_SSH_COLOR="%F{white}%K{red}"

# hostname
# export ZSH_PROMPT_HOSTNAME="example.com"
' > "$private_zsh_dir/private.zshenv.zsh"
  fi

  [[ -e "$private_zsh_dir/private.zshrc.zsh" ]] || : > "$private_zsh_dir/private.zshrc.zsh"
}

#
# Load settings which should not be committed to the repository.
#

source "$HOME/.config/zsh/private.zshrc.zsh"

#
# Set prompt
#

source "$HOME/.local/share/zsh-config/prompt.zsh"
