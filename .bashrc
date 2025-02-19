export XDG_CONFIG_HOME="$HOME/.config"

# Aliases

## Bash
alias ls="ls -la"
alias sb="source ~/.bashrc"

## Tmux
alias t="tmux"
alias ta="t new -A -s"
alias tl="t ls"
alias tk="t kill-session -t"

## Neovim
alias v=nvim
alias vim=nvim
alias vv="nvim ~/.config/nvim/init.lua"
alias vb="nvim ~/dot/.bashrc"
alias vs="nvim ~/.config/starship.toml"
alias vd="nvim ~/dot"
alias vi="nvim ~/dot/scripts/init.sh"
alias vh="nvim ~/.config/hammerspoon/init.lua"
alias vt="nvim ~/.config/wezterm/wezterm.lua"

## Git
alias gcam="git commit -am"
alias gd="git diff"
alias gp="git push"
alias ga="git add ."
alias gs="git status"
alias gf="git commit -am 'Update' && gp"
alias gu="git pull"
alias dgf="pushd ~/dot && gf && popd"
alias dgu="pushd ~/dot && gu && popd"

## Editor
export EDITOR=nvim
export VISUAL=nvim

# PATH
export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/bin:"$PATH"
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH=/home/linux/.linuxbrew/bin:"$PATH"
fi

# Terminal
eval "$(starship init bash)"

# User-defined functions
weather() {
   curl wttr.in/$1
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_CTRL_R_OPTS="
  --prompt 'History > '
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-t:track+clear-query'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic"


if [[ $(command -v gcert) && "$OSTYPE" == "linux-gnu"* ]]; then
  alias copybara="/google/data/ro/teams/copybara/copybara"
  alias aclcheck="/google/data/ro/projects/ganpati/aclcheck"
  alias perfgate="/google/bin/releases/perfgate/cli/perfgate"
  alias pastebin="/google/src/head/depot/eng/tools/pastebin"
  alias bisect="/google/data/ro/teams/tetralight/bin/bisect"
  alias t=tmx2
  alias vgb="nvim $HOME/google/.bashrc"
  alias gfg="pushd ~/google && gf && popd"

  bisect_cl() {
    bisect -low $1 -high $2 \
      'hg sync "cl($X,exact=False)" && rabbit test --tool_tag=rabbit_cli_scripted --symlink_prefix=/tmp/output/blaze- \ "$3"'
  }

  # TGP
  tgp() {
    CL=$1
    shift
    tap_presubmit --email --detach -c $CL -p all --skip_flaky_targets --skip_already_failing $@
  }
  tgp_exotic() {
    CL=$1
    shift
    tap_presubmit --email --detach -c $CL -p all --skip_flaky_targets --skip_already_failing --skip_exotic_targets=false $@
  }
  tgp_sample() {
    CL=$1
    shift
    tap_presubmit --email --detach -c $CL -p all --skip_flaky_targets --skip_already_failing --sample --sample_size=40000 $@
  }
  tgp_train() {
    CL=$1
    shift
     tap_presubmit --email --detach --train -c $CL $@
  }
  # blake says this will run even in the day - a TGP against tpu targets!
  tgp_tpus_only() {
    CL=$1
    shift
    tap_presubmit --email --detach -c $CL -p all --test_tag_filters=requires-jellyfish,requires-dragonfish,requires-viperfish,requires-viperfish:4,requires-viperlite,requires-viperlite:8,requires-pufferfish:4,requires-pufferfish,requires-puffylite --skip_exotic_targets=false $@
  }
  tgp_exotic_only() {
    CL=$1
    shift
    tap_presubmit --email --detach -c $CL -p all --test_tag_filters=requires-jellyfish,requires-dragonfish,requires-viperfish,requires-viperfish:4,requires-viperlite,requires-viperlite:8,requires-pufferfish:4,requires-pufferfish,requires-puffylite,requires-gpu-nvidia --skip_exotic_targets=false $@
  }
fi
