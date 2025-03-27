if status is-login
    if test -z "$DISPLAY" && test "$(tty)" = "/dev/tty1"
        exec sway
    end
end

if status --is-interactive
    starship init fish | source
end

function fish_greeting
    if test "$TERM" = "foot"
        fastfetch -c ~/.config/fastfetch/presets/simple.jsonc
    end
end

##############
## VARIABLE ##
##############

set -x MOZ_ENABLE_WAYLAND 1
set -x QT_QPA_PLATFORM wayland
set -x QT_STYLE_OVERRIDE kvantum
set -x XDG_CURRENT_DESKTOP Sway
set -x GTK_THEME Tokyonight-Dark
set -x EDITOR micro



###########
## ALIAS ##
###########

alias sudo='sudo '
alias c=clear
alias mi=micro
alias code=codium
alias start='sudo systemctl start '
alias stop='sudo systemctl stop '
alias ff=fastfetch

# Sway
alias getappid="swaymsg -t get_tree | jq '.. | select(.app_id?) | .app_id' | sort -u"
alias getapptitle="swaymsg -t get_tree | jq '.. | select(.name?) | .name' | sort -u"

#MPV
alias music='~/.scripts/music.sh'

# Package
alias paccek='yay -Q | grep '
alias upgrade='yay -Syu && flatpak upgrade'

# Git
alias gi='git init'
alias gs='git status'
alias ga='git add .'
alias gcm='git commit -m '
alias gp='git push'
alias gc='git clone '
alias grh='git reset --hard '
alias grr='git remote remove '

# Recording Video
alias record='~/.scripts/record_wayland.sh'

# Docker
alias cleandock='docker rm -f $(docker ps -a -q) && docker rmi -f $(docker images -a -q) && docker volume rm $(docker volume ls -q) && docker network rm $(docker network ls -q)'

alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias hw='hwinfo --short'                                   # Hardware Info
alias update='sudo pacman -Syu'
alias mirror="sudo cachyos-rate-mirrors"
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"
alias clrjctl="sudo journalctl --vacuum-time=1s"
