# igual se queda el systemd-boot de la primera generacion, se debe borrar manualmente. 
# Ejecute:

efibootmgr
sudo rm -rf /boot/loader                          
sudo rm -rf /boot/EFI/systemd

#se elimina el que diga Linux Boot Manager porque este es systemd-boot
sudo efibootmgr -b XXXX -B     

#Reinstalar y registrar GRUB forzadamente
sudo nixos-rebuild  boot --install-bootloader --flake .

