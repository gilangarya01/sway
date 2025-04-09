#!/bin/bash

# ========== Colors ==========
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

# ========== Utility Functions ==========
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ========== Package Lists ==========
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
  micro
  brightnessctl
  cliphist
  grim
  starship
  polkit-gnome
  autotiling
  mpv
  yt-dlp
  viewnior
  hyprpicker
  xdg-user-dirs
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
)

AUR_PKGS=(
  swaylock-effects
)

# ========== Functions ==========
install_yay() {
  if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/yay
    success "yay installed successfully!"
  else
    success "yay is already installed."
  fi
}

install_packages() {
  info "Installing packages with pacman..."
  sudo pacman -Syu --noconfirm "${PACMAN_PKGS[@]}"
}

install_aur_packages() {
  info "Installing AUR packages with yay..."
  yay -S --noconfirm "${AUR_PKGS[@]}"
  success "AUR packages installed successfully."
}

clone_dotfiles() {
  info "Copying dotfiles to home directory..."
  cp -r ./.config ~/
  cp -r ./.icons ~/
  cp -r ./.themes ~/
  cp -r ./.scripts ~/
  cp -r ./Pictures ~/
  success "Dotfiles copied successfully."
}

# ========== Execution ==========
info "Starting dotfiles and environment setup..."

install_yay
install_packages
install_aur_packages
clone_dotfiles

success "Installation complete! Please reboot and start Sway using the 'sway' command."
