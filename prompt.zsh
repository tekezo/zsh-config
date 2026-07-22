function _prompt_git() {
  if [[ -n "$NO_GIT" ]]; then
    print -r -- 'no git'
    return
  fi

  local branch revision message full
  branch=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  revision=$(command git log --pretty=format:'%h' -n 1 2>/dev/null) || return
  message=$(command git log --pretty=format:'%s' -n 1 2>/dev/null)
  message=${message[1,55]}
  full="%B${branch}%b | ${revision} | %K{black}%F{cyan}${message}"
  print -r -- "${full[1,95]}%k"
}

function _prompt_inherit_ssh_auth_sock() {
  [[ -n "$TMUX" && $+commands[tmux] -eq 1 ]] || return

  local value
  value=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null) || return
  [[ "$value" == SSH_AUTH_SOCK=* ]] || return
  value=${value#SSH_AUTH_SOCK=}
  [[ -S "$value" ]] && export SSH_AUTH_SOCK="$value"
}

() {
  setopt PROMPT_SUBST
  autoload -Uz add-zsh-hook

  _prompt_inherit_ssh_auth_sock
  add-zsh-hook preexec _prompt_inherit_ssh_auth_sock

  local remote_indicator='🏠 local %B'
  local remote_color='%F{white}'
  : ${ZSH_PROMPT_SSH_COLOR:='%F{white}%K{green}'}
  if [[ -n "$SSH_TTY" ]]; then
    remote_indicator='⛺️ ssh %B'
    remote_color=$ZSH_PROMPT_SSH_COLOR
  fi
  : ${ZSH_PROMPT_HOSTNAME:='%M'}

  PROMPT="
🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁🏁
⏰ %F{white}%D{%F %T %Z}%f
${remote_color}${remote_indicator}${ZSH_PROMPT_HOSTNAME}%b%f%k %F{magenta}@%n%f
📁 %F{green}%d%f
🔀 %F{cyan}"'$(_prompt_git)'"%f
 %B%F{1}❯%F{3}❯%F{2}❯%f%b "
  RPROMPT=''
}
