

#por alguna razon en las ultimas instalaciones no carga el arranque correcto y tengo que setear el que es. Verifica que si sea el directorio correcto.
echo "are u sure?? es la ruta correcta??"
sleep 3

efibootmgr \
  --create \
  --disk /dev/nvme0n1 \
  --part 1 \
  --label "NixOS GRUB" \
  --loader '\EFI\Boot\bootx64.efi'

