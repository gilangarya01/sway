#!/bin/bash

# ========== Warna ==========
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

# ========== Fungsi Utilitas ==========
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ========== Daftar Paket ==========
PACMAN_PKGS=(
  ttf-0xproto-nerd
  xorg-xwayland
  wl-clipboard
  sway
  waybar
  foot
  fastfetch
  thunar 
  thunar-archive-plugin
  gvfs
  tumbler
  file-roller
  swaybg
  rofi-wayland
  dunst
  brightnessctl
  cliphist
  grim
  starship
  polkit-gnome
  autotilling
  mpv
  yt-dlp
  hyprpicker
  xdg-user-dirs
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
)

# ========== Fungsi ==========
install_yay() {
  if ! command -v yay &>/dev/null; then
    info "Menginstal yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/yay
    success "yay berhasil diinstal!"
  else
    success "yay sudah terinstal."
  fi
}

install_packages() {
  info "Menginstal paket dengan pacman..."
  sudo pacman -Syu --noconfirm "${PACMAN_PKGS[@]}"
}

clone_dotfiles() {
  info "Menyalin dotfiles ke home directory..."
  cp -r .config ~/
  cp -r .local ~/
  cp -r .icons ~/
  cp -r .themes ~/
  cp -r .scripts ~/
  cp -r Pictures ~/
  success "Dotfiles berhasil disalin."
}


# ========== Eksekusi ==========
info "Memulai setup dotfiles dan lingkungan kerja..."

install_yay
install_packages
clone_dotfiles

success "Instalasi selesai! Silakan reboot dan jalankan Sway dengan perintah 'sway'."
