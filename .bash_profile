if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

if [[ $(command -v rw) ]]; then
  alias s="rw dsuo.c.googlers.com"
fi

