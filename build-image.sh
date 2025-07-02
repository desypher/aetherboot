#!/bin/bash
set -euo pipefail

# Color codes for pretty output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Helper functions for printing
info()   { echo -e "${CYAN}[+]" "$@" "${RESET}"; }
success(){ echo -e "${GREEN}[✓]" "$@" "${RESET}"; }
warn()   { echo -e "${YELLOW}[!]" "$@" "${RESET}"; }
error()  { echo -e "${RED}[✗]" "$@" "${RESET}"; }

# Paths
EFI_STUB="/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
KERNEL_IMAGE="/boot/vmlinuz-linux"
INIT_SCRIPT="./init"
BUSYBOX="/usr/bin/busybox"
BOOTLOADER="./build/aetherboot"
OUTPUT_IMG="aetherboot.img"
INITRAMFS_IMG="initramfs.img"

info "Cleaning old files..."
rm -rf initramfs esp "$INITRAMFS_IMG" bootx64.efi "$OUTPUT_IMG"

info "Checking required files..."
for f in "$EFI_STUB" "$KERNEL_IMAGE" "$INIT_SCRIPT" "$BUSYBOX" "$BOOTLOADER"; do
    if [[ ! -f "$f" ]]; then
        error "Required file missing: $f"
        exit 1
    else
        echo -e "  ${GREEN}✔${RESET} $f"
    fi
done

info "Preparing initramfs directory structure..."
mkdir -p initramfs/{bin,dev,proc,sys,tmp,lib,usr/share/fonts/truetype/dejavu,lib64,usr/lib,usr/lib/qt6/plugins/platforms,usr/lib/qt6/qml/QtQuick/Controls/Basic,usr/lib/qt6/qml/QtQuick/Controls/Fusion/impl,usr/lib/qt6/qml/QtQuick/Layouts,usr/lib/qt6/qml/QtQuick,usr/share/X11}

info "Copying core files..."
cp "$INIT_SCRIPT" initramfs/init && chmod +x initramfs/init || { error "Failed to make init executable"; exit 1; }
cp "$BOOTLOADER" initramfs/aetherboot && chmod +x initramfs/aetherboot
cp "$BUSYBOX" initramfs/bin/busybox && chmod +x initramfs/bin/busybox

info "Creating BusyBox symlinks..."
for cmd in sh mount mkdir echo; do
  ln -sf busybox "initramfs/bin/$cmd"
done

info "Creating device nodes..."
mkdir -p initramfs/dev
if [[ ! -e initramfs/dev/fb0 ]]; then
  sudo mknod -m 0666 initramfs/dev/fb0 c 29 0
  success "Created /dev/fb0 node"
fi

info "Copying keyboard layouts..."
if [[ -d /usr/share/X11/xkb ]]; then
  mkdir -p initramfs/usr/share/X11
  cp -r /usr/share/X11/xkb initramfs/usr/share/X11/
  success "Copied /usr/share/X11/xkb"
else
  warn "/usr/share/X11/xkb not found on host"
fi

info "Copying QtQuick Layouts plugin and dependencies..."
cp /usr/lib/qt6/qml/QtQuick/Layouts/libqquicklayoutsplugin.so initramfs/usr/lib/qt6/qml/QtQuick/Layouts/
ldd /usr/lib/qt6/qml/QtQuick/Layouts/libqquicklayoutsplugin.so | awk '{print $3}' | grep -E '^/' | while read -r lib; do
  dest="initramfs${lib}"
  mkdir -p "$(dirname "$dest")"
  cp -v "$lib" "$dest"
done
cp /usr/lib/libQt6QuickLayouts.so.6 initramfs/usr/lib/

info "Copying Fusion style plugin and dependencies..."
mkdir -p initramfs/usr/lib/qt6/qml/QtQuick/Controls/Fusion/impl
cp /usr/lib/qt6/qml/QtQuick/Controls/Fusion/impl/libqtquickcontrols2fusionstyleimplplugin.so initramfs/usr/lib/qt6/qml/QtQuick/Controls/Fusion/impl/
ldd /usr/lib/qt6/qml/QtQuick/Controls/Fusion/impl/libqtquickcontrols2fusionstyleimplplugin.so | awk '{print $3}' | grep -E '^/' | while read -r lib; do
  dest="initramfs${lib}"
  mkdir -p "$(dirname "$dest")"
  cp -v "$lib" "$dest"
done
cp /usr/lib/qt6/qml/QtQuick/Controls/Fusion/libqtquickcontrols2fusionstyleplugin.so initramfs/usr/lib/qt6/qml/QtQuick/Controls/Fusion/
cp /usr/lib/libQt6QuickControls2Fusion.so.6 initramfs/usr/lib/

info "Copying essential libraries..."
cp /lib64/ld-linux-x86-64.so.2 initramfs/lib64/
cp /usr/lib/libc.so.6 initramfs/usr/lib/
cp /usr/lib/libresolv.so.2 initramfs/usr/lib/

info "Copying fontconfig configs and libraries..."
mkdir -p initramfs/etc/fonts
cp /etc/fonts/fonts.conf initramfs/etc/fonts/
cp -r /etc/fonts/conf.d initramfs/etc/fonts/
cp /usr/lib/libfontconfig.so.1 initramfs/usr/lib/
cp /usr/lib/libfreetype.so.6 initramfs/usr/lib/
cp /usr/lib/libpng16.so.16 initramfs/usr/lib/

info "Copying fonts..."
cp /usr/share/fonts/TTF/DejaVuSans.ttf initramfs/usr/share/fonts/truetype/dejavu/

info "Copying Qt platform plugin (linuxfb)..."
cp /usr/lib/qt6/plugins/platforms/libqlinuxfb.so initramfs/usr/lib/qt6/plugins/platforms/

info "Copying QtQuick Controls 2 QML files..."
cp -r /usr/lib/qt6/qml/QtQuick/Controls/* initramfs/usr/lib/qt6/qml/QtQuick/Controls/
cp -r /usr/lib/qt6/qml/QtQuick/* initramfs/usr/lib/qt6/qml/QtQuick/

info "[+] Copying X11 keyboard layouts..."
mkdir -p initramfs/usr/share/X11
cp -r /usr/share/X11/xkb initramfs/usr/share/X11/

info "[+] Copying Locales..."
mkdir -p initramfs/usr/lib/locale/
cp /usr/lib/locale/locale-archive initramfs/usr/lib/locale/

info "Copying Qt plugin dependencies..."
for binary in "$BOOTLOADER" /usr/lib/qt6/plugins/platforms/libqlinuxfb.so /usr/lib/qt6/qml/QtQuick/Controls/Basic/libqtquickcontrols2basicstyleplugin.so; do
  echo -e "${CYAN}  ➜ Copying dependencies for $binary${RESET}"
  ldd "$binary" | awk '{print $3}' | grep -E '^/' | while read -r lib; do
    dest="initramfs${lib}"
    mkdir -p "$(dirname "$dest")"
    cp -v "$lib" "$dest"
  done
done

cp /usr/lib/qt6/qml/QtQuick/Controls/Basic/libqtquickcontrols2basicstyleplugin.so initramfs/usr/lib/qt6/qml/QtQuick/Controls/Basic/

info "Creating symlink for Qt plugin compatibility..."
mkdir -p initramfs/usr/lib/qt
ln -sf /usr/lib/qt6/plugins/platforms initramfs/usr/lib/qt/plugins

info "Copying fonts folder (full)..."
cp -r /usr/share/fonts initramfs/usr/share/

info "Verifying essential initramfs files..."
for f in init aetherboot bin/busybox; do
  if [[ -x "initramfs/$f" ]]; then
    success "$f exists and is executable"
  else
    error "$f missing or not executable"
    exit 1
  fi
done

info "Creating initramfs image..."
cd initramfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../"$INITRAMFS_IMG"
cd ..

info "Verifying packed initramfs contents..."
TMPDIR=$(mktemp -d)
cd "$TMPDIR"
gzip -dc /home/brynn/aetherboot/"$INITRAMFS_IMG" | cpio -idmv >/dev/null 2>&1
for f in init aetherboot bin/busybox; do
  if [[ -x "$f" ]]; then
    success "$f found in packed initramfs"
  else
    error "$f missing in packed initramfs"
    exit 1
  fi
done
cd - >/dev/null
rm -rf "$TMPDIR"

info "Writing kernel command line..."
echo "quiet loglevel=3 init=/init console=ttyS0,115200n8 LANG=C.UTF-8 LC_ALL=C.UTF-8" > cmdline.txt

info "Creating unified EFI binary..."
objcopy \
  --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x14DFA0000 \
  --add-section .cmdline=cmdline.txt --change-section-vma .cmdline=0x14DFB0000 \
  --add-section .linux="$KERNEL_IMAGE" --change-section-vma .linux=0x150000000 \
  --add-section .initrd="$INITRAMFS_IMG" --change-section-vma .initrd=0x151000000 \
  "$EFI_STUB" bootx64.efi

info "Creating 256MB disk image..."
dd if=/dev/zero of="$OUTPUT_IMG" bs=1M count=256 status=progress

info "Creating GPT partition table and EFI partition..."
sgdisk -o "$OUTPUT_IMG"
sgdisk -n 1:2048:-1 -t 1:ef00 -c 1:"EFI System Partition" "$OUTPUT_IMG"

info "Mounting and copying EFI binary..."
LOOPDEV=$(sudo losetup -Pf --show "$OUTPUT_IMG")
MNTDIR=$(mktemp -d)
sudo mkfs.vfat -F 32 "${LOOPDEV}p1"
sudo mount "${LOOPDEV}p1" "$MNTDIR"
sudo mkdir -p "$MNTDIR/EFI/BOOT"
sudo cp bootx64.efi "$MNTDIR/EFI/BOOT/BOOTX64.EFI"
sync
sudo umount "$MNTDIR"
sudo losetup -d "$LOOPDEV"
rmdir "$MNTDIR"

success "Aetherboot.img successfully built!"
