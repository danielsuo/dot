# Aliases

## Bash
alias ls="ls -la"
alias sb="source ~/.bashrc"

## Neovim
alias v=nvim
alias vim=nvim
alias vc="nvim ~/.config/nvim/init.lua"
alias vb="nvim ~/.bashrc"
alias vs="nvim ~/.config/starship.toml"

## Git
alias gcam="git commit -am"
alias gp="git push"
alias ga="git add ."
alias gs="git status"

# PATH
export PATH="$HOME/.local/bin:$PATH"

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH=/opt/homebrew/bin:"$PATH"
fi

# Terminal
eval "$(starship init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
