#!/bin/bash
set -euo pipefail

# --- Paths and filenames (adjust if needed) ---
EFI_STUB="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
KERNEL_IMAGE="/boot/vmlinuz-linux"
OUTPUT_IMG="aetherboot.img"
INITRAMFS_IMG="initramfs.img"
CMDLINE_TXT="cmdline.txt"

INIT_SCRIPT="./init"          # Your init script (must be executable)
BUSYBOX="./busybox"           # Busybox binary (must be executable)
AETHERBOOT="./build/aetherboot" # Your built aetherboot binary

# --- Clean old files ---
rm -rf initramfs "$INITRAMFS_IMG" bootx64.efi "$OUTPUT_IMG" "$CMDLINE_TXT"

# --- Check prerequisites ---
for f in "$EFI_STUB" "$KERNEL_IMAGE" "$INIT_SCRIPT" "$BUSYBOX" "$AETHERBOOT"; do
  if [[ ! -f "$f" ]]; then
    echo "❌ Required file not found: $f"
    exit 1
  fi
done

echo "[+] Preparing initramfs..."

mkdir -p initramfs/{bin,dev,proc,sys,tmp,lib,usr/share/fonts}
cp "$INIT_SCRIPT" initramfs/init
chmod +x initramfs/init
cp "$AETHERBOOT" initramfs/aetherboot
cp "$BUSYBOX" initramfs/bin/
chmod +x initramfs/bin/busybox

# Create symlinks for busybox utilities
for cmd in sh mount mkdir echo; do
  ln -sf busybox initramfs/bin/$cmd
done

# Copy shared libraries for aetherboot (adjust for your system)
ldd "$AETHERBOOT" | awk '{print $3}' | grep -E '^/' | xargs -I '{}' cp -v '{}' initramfs/lib/

# Copy fonts (optional, if your app needs it)
cp -r /usr/share/fonts initramfs/usr/share/

echo "[+] Creating initramfs.img..."
pushd initramfs >/dev/null
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../"$INITRAMFS_IMG"
popd >/dev/null

echo "quiet loglevel=3" > cmdline.txt

echo "[+] Creating unified EFI binary bootx64.efi..."
objcopy \
  --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
  --add-section .cmdline="$CMDLINE_TXT" --change-section-vma .cmdline=0x30000 \
  --add-section .linux="$KERNEL_IMAGE" --change-section-vma .linux=0x1000000 \
  --add-section .initrd="$INITRAMFS_IMG" --change-section-vma .initrd=0x3000000 \
  "$EFI_STUB" bootx64.efi

echo "[+] Creating 256MB GPT-partitioned disk image..."
dd if=/dev/zero of="$OUTPUT_IMG" bs=1M count=256

echo "[+] Creating GPT partition table and EFI partition..."
sgdisk -o "$OUTPUT_IMG"
sgdisk -n 1:2048:-1 -t 1:ef00 -c 1:"EFI System Partition" "$OUTPUT_IMG"

echo "[+] Setting up loop device..."
LOOPDEV=$(sudo losetup -Pf --show "$OUTPUT_IMG")
echo "Loop device: $LOOPDEV"

echo "[+] Formatting EFI partition as FAT32..."
sudo mkfs.vfat -F 32 "${LOOPDEV}p1"

echo "[+] Mounting EFI partition and copying EFI binary..."
MNTDIR=$(mktemp -d)
sudo mount "${LOOPDEV}p1" "$MNTDIR"
sudo mkdir -p "$MNTDIR/EFI/BOOT"
sudo cp bootx64.efi "$MNTDIR/EFI/BOOT/BOOTX64.EFI"

sync
sudo umount "$MNTDIR"
sudo losetup -d "$LOOPDEV"
rmdir "$MNTDIR"

echo "[✓] Build complete! To boot, run QEMU with this command:"
echo ""
echo "qemu-system-x86_64 \\"
echo "  -enable-kvm -m 2048 \\"
echo "  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \\"
echo "  -drive if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS_4M.fd \\"
echo "  -drive format=raw,file=$OUTPUT_IMG \\"
echo "  -vga std"
echo ""