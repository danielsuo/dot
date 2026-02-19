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
export PATH="$HOME"/go/bin:$PATH

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
bindkey '\ef' forward-word
bindkey '\eb' backward-word

autoload -Uz compinit
compinit

################################################################################
# SSH
################################################################################
if [[ $(command -v gcert) ]]; then
  alias s="ssh dsuo.c.googlers.com"
  alias sw="rw dsuo.c.googlers.com"
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
# Agentic
################################################################################
j() {
  blaze run --nocheck_visibility --norun_validations  //learning/gemini/gemax/experimental/unagi/demos:jarvis -- --logtostderr --prompt "$*"
}
alias g='/google/bin/releases/gemini-cli/tools/gemini'
alias gemini='/google/bin/releases/gemini-cli/tools/gemini'

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
alias vg="nvim ~/.config/ghostty/config"

################################################################################
# Tmux
################################################################################
alias tls="tmux list-sessions"
ta() {
    local session_name="${1:-main}"

    # Check if session exists (suppress error output)
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach-session -t "$session_name"
    else
        tmux new-session -s "$session_name"
    fi
}

################################################################################
# Git
################################################################################
alias gcam="git commit -am"
alias gd="git diff"
alias gb="git branch"
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
  cd ~/src/jax && a "$1" && pip install -e .
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
# UTILS
################################################################################
sync_dirs() {
    # Check if two arguments (source and destination directories) were provided
    if [ "$#" -ne 2 ]; then
        echo "Usage: sync_new_files <source_directory> <destination_directory>"
        return 1
    fi

    local SOURCE_DIR="$1"
    local DEST_DIR="$2"

    # Ensure source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error: Source directory '$SOURCE_DIR' not found."
        return 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$DEST_DIR" ]; then
        echo "Destination directory '$DEST_DIR' not found. Creating it..."
        mkdir -p "$DEST_DIR"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create destination directory."
            return 1
        fi
    fi

    echo "Starting synchronization from $SOURCE_DIR to $DEST_DIR..."

    # Iterate through all files in the source directory (including subdirectories)
    # The find command helps process all files recursively
    find "$SOURCE_DIR" -type f -print0 | while IFS= read -r -d '' SOURCE_FILE; do
        # Calculate the relative path of the file
        RELATIVE_PATH="${SOURCE_FILE#"$SOURCE_DIR/"}"
        # Construct the full path in the destination directory
        DEST_FILE="$DEST_DIR/$RELATIVE_PATH"
        # Check if the file exists in the destination
        if [ ! -f "$DEST_FILE" ]; then
            echo "Copying new file: $RELATIVE_PATH"
            # Ensure the destination directory structure exists before copying
            DEST_DIR_PATH=$(dirname "$DEST_FILE")
            if [ ! -d "$DEST_DIR_PATH" ]; then
                mkdir -p "$DEST_DIR_PATH"
            fi
            # Copy the file, preserving metadata (p)
            cp -p "$SOURCE_FILE" "$DEST_FILE"
        # else
        #     echo "File already exists, skipping: $RELATIVE_PATH"
        fi
    done

    echo "Synchronization complete."
}

sync_date() {
  sync_dirs "/Users/dsuo/Pictures/$1" "/Volumes/homes/dsuo/Photos/$1"
}

[[ -f ~/.google.zshrc ]] && source ~/.google.zshrc

