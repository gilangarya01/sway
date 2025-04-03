# Jika sesi login dan berada di tty1, jalankan Sway
if status is-login
    if test -z "$DISPLAY" && test (tty) = /dev/tty1
        exec sway
    end
end

# Inisialisasi Starship jika sesi interaktif
if status --is-interactive
    starship init fish | source
end

# Menampilkan Fastfetch jika terminal adalah foot
function fish_greeting
    if test "$TERM" = foot
        fastfetch -c ~/.config/fastfetch/presets/simple.jsonc
    end
end

##############
## VARIABEL ##
##############

set -gx MOZ_ENABLE_WAYLAND 1
set -gx QT_QPA_PLATFORM wayland
set -gx XDG_CURRENT_DESKTOP Sway
set -gx GTK_THEME Tokyonight-Dark
set -gx EDITOR micro

###########
## ALIAS ##
###########

alias sudo='sudo ' # Memastikan sudo tidak menghapus alias berikutnya
alias c=clear
alias mi=micro
alias start='sudo systemctl start '
alias stop='sudo systemctl stop '
alias ff=fastfetch
alias fishconfig='micro ~/.config/fish/config.fish'

# Sway
alias getappid="swaymsg -t get_tree | jq '.. | select(.app_id?) | .app_id' | sort -u"
alias getapptitle="swaymsg -t get_tree | jq '.. | select(.name?) | .name' | sort -u"

# MPV
alias music='~/.scripts/music.sh'

# Paket manajemen
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

# Rekaman layar
alias record='~/.scripts/record_wayland.sh'

# Docker (Membersihkan semua container, images, volume, dan network)
alias cleandock='docker container prune -f && docker volume prune -f && docker network prune -f'

# Perintah sistem
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias hw='hwinfo --short' # Informasi hardware
alias update='sudo pacman -Syu'
alias mirror="sudo cachyos-rate-mirrors"
alias ls='eza -al --color=always --group-directories-first --icons' # Pengganti ls dengan eza

# Membersihkan paket yatim (orphaned packages)
function cleanup
    set orphaned (pacman -Qtdq)
    if test -n "$orphaned"
        sudo pacman -Rns $orphaned
    else
        echo "Tidak ada paket untuk dibersihkan."
    end
end

# Mendapatkan error dari journalctl
alias jctl="journalctl -p 3 -xb"
alias clrjctl="sudo journalctl --vacuum-time=1s"

##################
## SNAPSHOTTER ##
##################

# List snapshots
function snapper-list
    sudo snapper -c root list
end

# Create snapshot dengan deskripsi opsional
function snapper-create
    if test (count $argv) -eq 0
        echo "Usage: snapper-create <description>"
        return 1
    end
    sudo snapper -c root create -d "$argv"
end

# Delete snapshot dengan konfirmasi
function snapper-delete
    if test (count $argv) -eq 0
        echo "Usage: snapper-delete <snapshot_number>"
        return 1
    end
    read -l -P "Are you sure you want to delete snapshot $argv? (y/N) " confirm
    if test "$confirm" = "y"
        sudo snapper -c root delete $argv
    else
        echo "Deletion canceled."
    end
end

# Rollback snapshot
function snapper-rollback
    if test (count $argv) -eq 0
        echo "Usage: snapper-rollback <snapshot_number>"
        return 1
    end
    sudo snapper -c root rollback $argv
end
