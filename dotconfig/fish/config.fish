# tokyo-void Fish Config
if status is-interactive
    starship init fish | source
end

alias ls="eza --icons"
alias ll="eza -lh --icons"
alias la="eza -a --icons"
alias tree="eza --tree --icons"
alias xi="sudo xbps-install"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

set -gx EDITOR nvim
set -gx VISUAL nvim

# Development Paths
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.npm-global/bin

# Podman socket setup
if not test -S /run/user/1000/podman/podman.sock
    podman system service --time=0 unix:///run/user/1000/podman/podman.sock &
end
