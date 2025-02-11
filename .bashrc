# Aliases

## Neovim
alias v=nvim
alias vim=nvim
alias vc="nvim ~/.config/nvim/init.lua"
alias vb="nvim ~/.bashrc"

## Git
alias gcam="git commit -am"
alias gp="git push"
alias ga="git add ."
alias gs="git status"

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Terminal
eval "$(starship init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
