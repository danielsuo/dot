################################################################################
# Exports
################################################################################
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export VISUAL=nvim

################################################################################
# PATH
################################################################################
export PATH="$HOME"/.local/share/../bin:$PATH

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/bin:"$PATH"
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$HOME"/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/bin:"$PATH"
fi

################################################################################
# Terminal
################################################################################
eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/config.toml)"

setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -e

autoload -Uz compinit
compinit

################################################################################
# SSH
################################################################################
if [[ $(command -v gcert) ]]; then
  alias s="ssh dsuo.c.googlers.com"
  alias sd="rw dsuo.c.googlers.com"
  alias sg="gcloud compute ssh --zone us-central1-f dsuo-a100 --project jax-dev"
  alias sc="gcloud compute ssh --zone us-central1-a dsuo-cpu --project jax-dev"
fi

################################################################################
# Zsh
################################################################################
alias ls="ls -la"
alias sz="source ~/.config/zsh/.zshrc"
export HISTFILE=~/.config/zsh/.histfile
export HISTSIZE=1000
export SAVEHIST=1000

################################################################################
# LLVM
################################################################################
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

################################################################################
# Neovim
################################################################################
alias v=nvim
alias vim=nvim
alias vd="nvim ~/dot"
alias vinit="nvim ~/dot/.init"
alias vh="nvim ~/.config/hammerspoon/init.lua"
alias vo="nvim ~/.config/oh-my-posh/config.toml"
alias vt="nvim ~/.config/tmux/tmux.conf"
alias vv="nvim ~/.config/nvim/init.lua"
alias vw="nvim ~/.config/wezterm/wezterm.lua"
alias vz="nvim ~/.config/zsh/.zshrc"

################################################################################
# Git
################################################################################
alias gcam="git commit -am"
alias gd="git diff"
alias gp="git push"
alias ga="git add ."
alias gs="git status"
alias gf="git commit -am 'Update' && gp"
alias gu="git pull"
alias gn="git checkout -b"
alias go="git checkout"
alias gl="git log --graph --pretty='format:%C(auto)%h %d %s %C(green)%an%C(bold blue) %ad' --all --date=relative"
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
# Python
################################################################################
alias d=deactivate
alias pip="uv pip"

function wt() {
  test=${1:-}
  pytest-watcher . --pdb -v -s --log-cli-level=INFO "$test"
}
function wf() {
  file=${1:-'${watch_src_path}'}
  # TODO(dsuo): Drop into pdb conditionally on error, quit otherwise. Right
  # now, passing `-m pdb -c continue -c quit` quits unconditionally.
  watchmedo shell-command --patterns="**/*.*" --recursive --command="python ${file}" --drop
}
function a() {
  python=${2:-3.13}
  [ -f envs/$1/bin/activate ] || (mkdir -p envs && uv venv envs/$1 --python "${python}")
  source envs/$1/bin/activate
  pip install \
    absl-py \
    auditwheel \
    build \
    cloudpickle \
    dill \
    etils \
    filelock \
    flatbuffers \
    hypothesis \
    ipython \
    jaxlib \
    matplotlib \
    ml_dtypes \
    mpmath \
    numpy \
    opt-einsum \
    pandas \
    pillow \
    pytest \
    pytest-watcher \
    pytest-xdist \
    rich \
    scipy \
    scipy-stubs \
    setuptools \
    watchdog \
    wheel
}
export IPYTHONDIR=~/.config/ipython


################################################################################
# FZF
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
  location="${1:-Princeton}"
   curl wttr.in/"$location?u"
}

################################################################################
# JAX
################################################################################
function jd() {
  cd ~/src/jax && a "$1"
}

export JAX_TRACEBACK_FILTERING=off

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

  alias frm="fileutil rm -R -f"
  alias fbrm="fileutil recursivedeletegfsbackup --allow_recursivedeletegfsbackup_from_interactive_shell"


  alias bt="blaze test --define PYTYPE=FALSE --test_env=XLA_FLAGS='--xla_dump_to=sponge --xla_dump_hlo_pass_re=.*' --test_env=JAX_DUMP_IR_TO=sponge --test_env=JAX_TRACEBACK_FILTERING=off --test_arg=--alsologtostderr --test_output=all --test_strategy=local --test_sharding_strategy=disabled"
  btj() {
   TEST=$1
   shift
    blaze test --define PYTYPE=FALSE --test_env=XLA_FLAGS='--xla_dump_to=sponge --xla_dump_hlo_pass_re=.*' --test_env=JAX_DUMP_IR_TO=sponge --test_env=JAX_TRACEBACK_FILTERING=off --test_arg=--alsologtostderr --test_output=all --test_strategy=local --test_sharding_strategy=disabled third_party/py/jax/tests"$TEST" -c opt --config=cuda $@
  }
  alias rt="rabbit test --define PYTYPE=FALSE --test_env=XLA_FLAGS='--xla_dump_to=sponge --xla_dump_hlo_pass_re=.*' --test_env=JAX_DUMP_IR_TO=sponge --test_env=JAX_TRACEBACK_FILTERING=off --test_arg=--alsologtostderr --test_sharding_strategy=disabled --test_output=all"
  rtj() {
   TEST=$1
   shift
    rabbit test --define PYTYPE=FALSE --test_env=XLA_FLAGS='--xla_dump_to=sponge --xla_dump_hlo_pass_re=.*' --test_env=JAX_DUMP_IR_TO=sponge --test_env=JAX_TRACEBACK_FILTERING=off --test_arg=--alsologtostderr --test_sharding_strategy=disabled --test_output=all third_party/py/jax/tests"$TEST" -c opt --config=cuda $@
  }
  alias br="blaze run"
  alias minrl=/google/src/head/depot/google3/learning/deepmind/research/control/minrl/minrl.sh

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

