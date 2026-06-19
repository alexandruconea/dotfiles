#!/bin/bash
set -e

echo "==> Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
fi

echo "==> Installing packages..."
yay -S --needed - < packages.txt

echo "==> Copying dotfiles..."
cp -r .config/waybar ~/.config/
cp -r .config/ghostty ~/.config/
cp -r .config/mako ~/.config/
cp -r .config/wireplumber ~/.config/
cp -r .config/rofi ~/.config/
cp -r .config/swaync ~/.config/
cp -r .config/wallust ~/.config/
cp -r .config/waypaper ~/.config/
cp .config/hypr/hyprland.lua ~/.config/hypr/
cp .config/hypr/hyprlock.conf ~/.config/hypr/
cp .config/hypr/hypridle.conf ~/.config/hypr/

echo "==> Making scripts executable..."
chmod +x ~/.config/waybar/custom_modules/*.sh
chmod +x ~/.config/waybar/custom_modules/media/*.sh 2>/dev/null || true

echo ""
echo "==> Manual steps required:"
echo "    1. sudo pacman -S hypridle"
echo "    2. sudo cp system/set-power-profile /usr/local/bin/ && sudo chmod 755 /usr/local/bin/set-power-profile"
echo "    3. sudo cp system/sddm-update-theme /usr/local/bin/ && sudo chmod 755 /usr/local/bin/sddm-update-theme"
echo "    4. sudo cp system/sudoers-power /etc/sudoers.d/power-profile"
echo "    5. sudo cp system/sudoers-sddm  /etc/sudoers.d/sddm-theme"
echo ""
echo "Done! Log out and back in to apply all changes."
