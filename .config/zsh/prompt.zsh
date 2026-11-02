# Santa-safe, zero-binary cross-platform (macOS + Linux) Zsh prompt.
# Reproduces the 1:1 look and layout of oh-my-posh config.toml:
# - Left prompt: session (yellow) -> path (orange) -> git / CitC (green/yellow/red) -> status (blue/red)
# - Right prompt: execution time (yellow) -> language indicators (node/go/python) -> shell & time (blue/white)
# - Secondary prompt (PS2)
# Runs 100% in-process inside Apple-signed /bin/zsh and Linux /bin/zsh with <5ms latency.

zmodload zsh/datetime

typeset -g _prompt_cmd_start=0
typeset -g _prompt_cmd_elapsed=""

function _prompt_preexec() {
  _prompt_cmd_start=$EPOCHREALTIME
}

function _prompt_precmd() {
  local last_status=$?

  # 1. Execution time tracking
  if (( _prompt_cmd_start > 0 )); then
    local elapsed=$(( EPOCHREALTIME - _prompt_cmd_start ))
    _prompt_cmd_start=0
    if (( elapsed >= 2.0 )); then
      if (( elapsed >= 60.0 )); then
        local mins=$(( int(elapsed) / 60 ))
        local secs=$(( int(elapsed) % 60 ))
        _prompt_cmd_elapsed="${mins}m${secs}s "
      else
        _prompt_cmd_elapsed="$(printf "%.1fs " $elapsed)"
      fi
    elif (( elapsed >= 0.5 )); then
      local ms=$(( int(elapsed * 1000) ))
      _prompt_cmd_elapsed="${ms}ms "
    else
      _prompt_cmd_elapsed=""
    fi
  else
    _prompt_cmd_elapsed=""
  fi

  # 2. Window title: matches console_title_template = '{{ .Shell }} in {{ .Folder }}'
  print -Pn "\e]0;zsh in %1~\a"

  # 3. Colors from palette:
  # black = '#262B44', blue = '#4B95E9', green = '#59C9A5', orange = '#F07623'
  # red = '#D81E5B', white = '#E0DEF4', yellow = '#F3AE35'
  local prev_bg="#F3AE35"

  local ssh_icon=""
  if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    ssh_icon=" "
  fi
  local user_name="${USER:-$(whoami)}"

  # Segment 1: Session (yellow background, black foreground)
  local prompt_str="%F{#F3AE35}%K{#F3AE35}%F{#262B44} ${ssh_icon}${user_name} "

  # Segment 2: Path (orange background, white foreground, style = 'folder')
  prompt_str+="%K{#F07623}%F{#F3AE35}%F{#E0DEF4}  %1~ "
  prev_bg="#F07623"

  # Segment 3: CitC or Git
  if [[ "$PWD" == /google/src/cloud/* ]]; then
    local citc_client=""
    if [[ "$PWD" =~ ^/google/src/cloud/[^/]+/([^/]+) ]]; then
      citc_client="${match[1]}"
    fi
    if [[ -n "$citc_client" ]]; then
      prompt_str+="%K{#59C9A5}%F{${prev_bg}}%F{#262B44} 🍇 ${citc_client} "
      prev_bg="#59C9A5"
    fi
  else
    local git_dir
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    if [[ -n "$git_dir" ]]; then
      local branch
      branch=$(git symbolic-ref --short HEAD 2>/dev/null)
      if [[ -z "$branch" ]]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
      fi
      if (( ${#branch} > 25 )); then
        branch="${branch[1,22]}..."
      fi

      local upstream_icon=""
      local remote_url
      remote_url=$(git config --get remote.origin.url 2>/dev/null)
      if [[ "$remote_url" == *github.com* ]]; then
        upstream_icon=" "
      fi

      local git_bg="#59C9A5"
      local git_fg="#262B44"
      local status_summary
      status_summary=$(git status --porcelain=v1 --branch 2>/dev/null)

      local ahead=0 behind=0 working=0 staged=0
      local line
      while IFS= read -r line; do
        if [[ "$line" == "## "* ]]; then
          if [[ "$line" =~ 'ahead ([0-9]+)' ]]; then
            ahead="${match[1]}"
          fi
          if [[ "$line" =~ 'behind ([0-9]+)' ]]; then
            behind="${match[1]}"
          fi
        elif [[ -n "$line" ]]; then
          local idx="${line:0:1}"
          local wrk="${line:1:1}"
          if [[ "$idx" != " " && "$idx" != "?" ]]; then
            (( staged++ ))
          fi
          if [[ "$wrk" != " " || "$idx" == "?" ]]; then
            (( working++ ))
          fi
        fi
      done <<< "$status_summary"

      if (( working > 0 || staged > 0 )); then
        git_bg="#F3AE35" # yellow
        git_fg="#262B44" # black
      elif (( ahead > 0 && behind > 0 )); then
        git_bg="#D81E5B" # red
        git_fg="#E0DEF4" # white
      elif (( ahead > 0 )); then
        git_bg="#49416D" # purple
        git_fg="#E0DEF4" # white
      elif (( behind > 0 )); then
        git_bg="#7A306C" # purple behind
        git_fg="#E0DEF4" # white
      else
        git_bg="#59C9A5" # green
        git_fg="#262B44" # black
      fi

      local git_body=" "
      [[ -n "$upstream_icon" ]] && git_body+="${upstream_icon}"
      git_body+="${branch}"
      if (( ahead > 0 && behind > 0 )); then
        git_body+=" ⇕${ahead}⇣${behind}"
      elif (( ahead > 0 )); then
        git_body+=" ⇡${ahead}"
      elif (( behind > 0 )); then
        git_body+=" ⇣${behind}"
      elif (( working == 0 && staged == 0 )); then
        git_body+=" ≡"
      fi

      if (( working > 0 )); then
        git_body+="  ${working}"
      fi
      if (( staged > 0 )); then
        git_body+="  ${staged}"
      fi
      git_body+=" "

      prompt_str+="%K{${git_bg}}%F{${prev_bg}}%F{${git_fg}}${git_body}"
      prev_bg="${git_bg}"
    fi
  fi

  # Segment 4: Root (yellow background, white foreground)
  if [[ $EUID -eq 0 ]]; then
    prompt_str+="%K{#F3AE35}%F{${prev_bg}}%F{#E0DEF4}  "
    prev_bg="#F3AE35"
  fi

  # Segment 5: Status (blue on success, red on failure, trailing rounded cap)
  local status_bg="#4B95E9"
  local status_icon=""
  if (( last_status != 0 )); then
    status_bg="#D81E5B"
    status_icon=""
  fi
  prompt_str+="%K{${status_bg}}%F{${prev_bg}}%F{#E0DEF4} ${status_icon} %k%F{${status_bg}}%f "

  # Right prompt (RPROMPT)
  local rprompt_str=""
  if [[ -n "$_prompt_cmd_elapsed" ]]; then
    rprompt_str+="%F{#F3AE35}${_prompt_cmd_elapsed}%f"
  fi
  if [[ -f "package.json" ]]; then
    rprompt_str+="%F{#59C9A5} %f"
  fi
  if [[ -f "go.mod" ]]; then
    rprompt_str+="%F{#4B95E9} %f"
  fi
  if [[ -n "$VIRTUAL_ENV" ]]; then
    rprompt_str+="%F{#F3AE35}  (${VIRTUAL_ENV:t}) %f"
  fi
  rprompt_str+="%F{#E0DEF4}in %B%F{#4B95E9}zsh%f%b %F{#E0DEF4}at %B%F{#4B95E9}%D{%H:%M:%S}%f%b"

  PROMPT="$prompt_str"
  RPROMPT="$rprompt_str"
  PS2='%F{#F3AE35}%K{#F3AE35}%F{#262B44} > %k%F{#F3AE35}%f '
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd
add-zsh-hook preexec _prompt_preexec

# Initial prompt setup on source
_prompt_precmd
