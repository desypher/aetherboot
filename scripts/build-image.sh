#!/bin/bash
# build-image.sh - Build UEFI bootable image for AetherBoot

set -e

IMAGE_NAME="aetherboot.img"
ESP_DIR="esp"
KERNEL_PATH="kernel/vmlinuz-linux"
INITRAMFS_PATH="initramfs/initramfs.img"
EFI_STUB="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
EFI_OUTPUT="$ESP_DIR/EFI/BOOT/BOOTX64.EFI"
CMDLINE_FILE=".cmdline"

# Clean previous build
rm -rf "$ESP_DIR" "$IMAGE_NAME"
mkdir -p "$ESP_DIR/EFI/BOOT"

# Create cmdline file
echo "quiet splash root=/dev/ram0 init=/init loglevel=3" > "$CMDLINE_FILE"

echo "[+] Building initramfs for AetherBoot..."
mkdir -p initramfs/{bin,sbin,etc,proc,sys,dev,tmp,usr/share/fonts}

# Copy files
cp aetherboot initramfs/
cp busybox initramfs/bin/
cp init initramfs/init
chmod +x initramfs/init

# Symlink essential BusyBox commands
for cmd in sh mount mkdir echo; do
  ln -s /bin/busybox initramfs/bin/$cmd
done

# Qt and system libs (adjust paths as needed)
mkdir -p initramfs/lib
cp /usr/lib/libQt6*.so* initramfs/lib/ || echo "Qt libs missing!"
cp /usr/lib/libc.so* initramfs/lib/ || echo "libc missing!"

# Fonts (optional but recommended for text rendering)
cp -r /usr/share/fonts initramfs/usr/share/ || echo "Fonts not found!"

# Create compressed initramfs
cd initramfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs/initramfs.img
cd ..

# Create combined EFI binary with stub, kernel, and initramfs
objcopy \
    --add-section .osrel=/etc/os-release \
    --add-section .cmdline="$CMDLINE_FILE" \
    --add-section .linux="$KERNEL_PATH" \
    --add-section .initrd="$INITRAMFS_PATH" \
    --change-section-vma .osrel=0x20000 \
    --change-section-vma .cmdline=0x30000 \
    --change-section-vma .linux=0x1000000 \
    --change-section-vma .initrd=0x3000000 \
    "$EFI_STUB" "$EFI_OUTPUT"

# Create a FAT32-formatted ESP image
dd if=/dev/zero of="$IMAGE_NAME" bs=1M count=64
mkfs.vfat "$IMAGE_NAME"
mmd -i "$IMAGE_NAME" ::/EFI
mmd -i "$IMAGE_NAME" ::/EFI/BOOT
mcopy -i "$IMAGE_NAME" "$EFI_OUTPUT" ::/EFI/BOOT

# Cleanup
echo "EFI bootable image created: $IMAGE_NAME"