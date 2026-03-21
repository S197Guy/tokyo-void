# tokyo-void Fish Config
if status is-interactive
    starship init fish | source
end

alias ls="eza --icons"
alias ll="eza -lh --icons"
alias la="eza -a --icons"
alias tree="eza --tree --icons"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

set -gx EDITOR nvim
set -gx VISUAL nvim
