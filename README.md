# dot
Public subset of dotfiles

## Requirements
- git
- make
- unzip
- gcc

# Getting started
## Ubuntu
```bash
sudo apt install git gh
yes | ssh-keygen -q -c "danielsuo@gmail.com" -t ed25519 -N '' -f "$HOME"/.ssh/id_ed25519 >/dev/null 2>&1
gh auth login -h github.com -p ssh -c -w
yes | git clone git@github.com:danielsuo/dot.git
pushd dot
./scripts/init.sh
popd
```

## MacOS
```bash
yes | ssh-keygen -q -C "danielsuo@gmail.com" -t ed25519 -N '' -f "$HOME"/.ssh/id_ed25519 >/dev/null 2>&1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
/opt/homebrew/bin/brew install gh
gh auth login -h github.com -p ssh -c -w
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone git@github.com:danielsuo/dot.git
pushd dot && ./scripts/init.sh && popd
```
