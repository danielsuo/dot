################################################################################
# EXPORTS
################################################################################
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export VISUAL=nvim

## PATH
# export PATH="$HOME/.local/bin:$HOME/miniforge3/bin:$PATH"  # commented out by conda initialize

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/bin:"$PATH"
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$HOME"/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/bin:"$PATH"
fi

## ZSH
export HISTFILE=~/.config/zsh/.histfile
export HISTSIZE=1000
export SAVEHIST=1000

################################################################################
# TERMINAL
################################################################################
eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/config.toml)"

setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -e

autoload -Uz compinit
compinit

################################################################################
# ALIASES
################################################################################

if [[ $(command -v gcert) ]]; then
  alias s="ssh dsuo.c.googlers.com"
  alias sd="rw dsuo.c.googlers.com"
  alias sg="gcloud compute ssh --zone us-central1-f dsuo-a100 --project jax-dev"
  alias sc="gcloud compute ssh --zone us-central1-a dsuo-cpu --project jax-dev"
fi

## Zsh
alias ls="ls -la"
alias sz="source ~/.config/zsh/.zshrc"

## Tmux
alias t="tmux"
alias ta="t new -A -s"
alias tl="t ls"
alias tk="t kill-session -t"

## Neovim
alias v=nvim
alias vim=nvim
alias vd="nvim ~/dot"
alias vi="nvim ~/dot/scripts/init.sh"
alias vh="nvim ~/.config/hammerspoon/init.lua"
alias vo="nvim ~/.config/oh-my-posh/config.toml"
alias vt="nvim ~/.config/tmux/tmux.conf"
alias vv="nvim ~/.config/nvim/init.lua"
alias vw="nvim ~/.config/wezterm/wezterm.lua"
alias vz="nvim ~/.config/zsh/.zshrc"

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
function gpru() {
 BRANCH="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
 git checkout main
 git branch -D $BRANCH
 git pull
 git checkout $BRANCH
}

################################################################################
# UI
################################################################################

[ -f ~/.config/fzf/fzf.zsh ] && source ~/.config/fzf/fzf.zsh
export FZF_CTRL_R_OPTS="
  --prompt 'History > '
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-t:track+clear-query'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic"

################################################################################
# USER-DEFINED FUNCTIONS
################################################################################
weather() {
   curl wttr.in/$1
}

################################################################################
# JAX
################################################################################

function jn() {
  git clone git@github.com:jax-ml/jax.git
  git clone git@github.com:openxla/xla.git
  conda create -y -n $1 python=3.13.2
  conda activate $1

  pushd jax
  gh pr checkout $1
  popd

  pushd xla
  gh pr checkout $2
  popd

  cd jax
  WHEELS=jaxlib
  if [[ "$(command -v nvidia-smi)" ]]; then
    WHEELS="$WHEELS",jax-cuda-plugin,jax-cuda-pjrt
  fi
  python build/build.py build --wheels="$WHEELS" --local_xla_path=../xla
  pip install -r build/test-requirements.txt

  if [[ "$(command -v nvidia-smi)" ]]; then
    pip install -e ".[cuda12]"
  else
    pip install -e .
  fi
  pip install dist/*.whl --force-reinstall
}

################################################################################
# GOOGLE
################################################################################
if [[ $(command -v gcert) && "$OSTYPE" == "linux-gnu"* ]]; then
  alias copybara="/google/data/ro/teams/copybara/copybara"
  alias aclcheck="/google/bin/releases/ganpati-acls/tools/aclcheck"
  alias perfgate="/google/bin/releases/perfgate/cli/perfgate"
  alias pastebin="/google/src/head/depot/eng/tools/pastebin"
  alias bisect="/google/data/ro/teams/tetralight/bin/bisect"
  alias floorcloth="/google/bin/releases/third-party-support/floorcloth/floorcloth"
  alias ml-actions-connect="/google/src/head/depot/google3/learning/brain/testing/github_actions/scripts/ml-actions-connect.sh"
  alias capabilities="/google/data/ro/projects/borg-sre/capabilities.par"
  alias perfgate="/google/bin/releases/perfgate/cli/perfgate"


  alias bt="blaze test --test_env=JAX_TRACEBACK_FILTERING=off --test_arg=--alsologtostderr --test_output=all"

  alias t=tmx2

  source /etc/bash_completion.d/hgd
  source /etc/bash_completion.d/g4d

  # source the common Brain bashrc (go/brain-bashrc)
  if [ -r /google/data/ro/teams/brain-frameworks/config/ml_bashrc ] ; then
      emulate sh -c 'source /google/data/ro/teams/brain-frameworks/config/ml_bashrc'
  fi

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

  if [ -r /google/data/ro/teams/deepmind-eng/config/bashrc ] ; then
    source /google/data/ro/teams/deepmind-eng/config/bashrc
  fi
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$($HOME'/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

