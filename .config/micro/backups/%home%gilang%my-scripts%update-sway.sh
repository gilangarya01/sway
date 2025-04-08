
REPO=~/Projects/sway

# Clear
rm -rf $REPO/.config $REPO/.local $REPO/.icons $REPO/.scripts $REPO/.themes $REPO/Pictures

# Make folder
mkdir -p $REPO/.config
mkdir -p $REPO/.local/share
mkdir -p $REPO/Pictures

# Fastfetch
cp -r ~/.config/fastfetch $REPO/.config

# Config
cp -r ~/.local/share/applications $REPO/.local/share
cp -r ~/.config/fish $REPO/.config
cp -r ~/.config/foot $REPO/.config
cp -r ~/.config/dunst $REPO/.config
cp -r ~/.config/micro $REPO/.config
cp -r ~/.config/rofi $REPO/.config
cp -r ~/.config/sway $REPO/.config
cp -r ~/.config/Thunar $REPO/.config
cp -r ~/.config/waybar $REPO/.config
cp -r ~/.config/mpv $REPO/.config
cp -r ~/.config/xfce4 $REPO/.config
cp -r ~/.config/starship.toml $REPO/.config

# Themes
cp -r ~/.icons $REPO
cp -r ~/.themes $REPO

# Wallpaper
cp -r ~/Pictures/Wallpaper  $REPO/Pictures

# GTK
cp -r ~/.config/gtk-3.0 $REPO/.config

# My Script
cp -r ~/.scripts $REPO





