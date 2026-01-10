echo "recuerda primero borrar lo que ya tengas en .config/nix"
sleep 3

sudo mv /etc/nixos/* /home/$USER/.config/nix/
sudo chown -R $USER:users ~/.config/nix/

sudo ln -s /home/$USER/.config/nix/* /etc/nixos/
