function _prompt_git() {
  if [[ -n $NO_GIT ]]; then
    print
    print -r -- 'no git'
    return
  fi

  local branch log revision message full
  branch=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  log=$(command git log --no-color --pretty=format:%h%n%s -n 1 2>/dev/null) || return
  revision=${log%%$'\n'*}
  message=${log#*$'\n'}

  # Make control characters visible so Git text cannot emit terminal escape sequences.
  branch=${(V)branch}
  message=${(V)message}

  # Escape percent signs so Git text is not interpreted as zsh prompt sequences.
  branch=${branch//\%/%%}
  message=${message//\%/%%}

  full="🔀 %F{blue}${branch} %F{black}| %F{cyan}${revision} %F{black}| %F{blue}${message}%f"
  local max_width=$(( COLUMNS - 4 ))
  print
  print -r -- "%${max_width}<…<${full}%<<"
}

function _prompt_inherit_ssh_auth_sock() {
  [[ -n $TMUX && $+commands[tmux] -eq 1 ]] || return

  local value
  value=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null) || return
  [[ $value == SSH_AUTH_SOCK=* ]] || return
  value=${value#SSH_AUTH_SOCK=}
  [[ -S $value ]] && export SSH_AUTH_SOCK=$value
}

() {
  setopt PROMPT_SUBST
  autoload -Uz add-zsh-hook

  _prompt_inherit_ssh_auth_sock
  add-zsh-hook preexec _prompt_inherit_ssh_auth_sock

  local remote_indicator='🏠 local '
  local remote_color='%F{yellow}'
  : ${ZSH_PROMPT_COLOR:='%F{yellow}'}
  if [[ -n $SSH_TTY ]]; then
    remote_indicator='⛺️ ssh '
    remote_color=$ZSH_PROMPT_COLOR
  fi
  : ${ZSH_PROMPT_HOSTNAME:='%M'}

  PROMPT="
⬆ ⏰ %F{yellow}%D{%F %T %Z}%f ⬆
\${(l:\$(( COLUMNS - 1 ))::─:)}
${remote_color}${remote_indicator}${ZSH_PROMPT_HOSTNAME}%f %F{magenta}@%n%f
📁 %F{green}%d%f\$(_prompt_git)

%# "
  RPROMPT=
}
