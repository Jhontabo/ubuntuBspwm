# Base shell config for Ubuntu BSPWM setup
export LANG=en_US.UTF-8
export EDITOR=vim

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ZSH plugins from distro packages
[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Powerlevel10k
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
