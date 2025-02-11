# Aliases

## Neovim
alias v=nvim
alias vim=nvim

## Git
alias gcam="git commit -am"
alias gp="git push"
alias ga="git add ."

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Terminal
eval "$(starship init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
