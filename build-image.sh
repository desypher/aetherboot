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

# Configuration
TEST_DIR="efi_test_env"
MAIN_DISK="main_system.img"
EXTRA_DISK1="extra_efi1.img" 
EXTRA_DISK2="extra_efi2.img"
USB_DISK="usb_efi.img"

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

# ADD INPUT DRIVER MODULES HERE
info "Copying input device kernel modules..."
KMODDIR="/lib/modules/6.15.4-arch2-1"
mkdir -p initramfs/lib/modules/6.15.4-arch2-1/kernel/drivers/{hid,input,usb}

# First, let's see what's actually available
info "Searching for input modules in $KMODDIR..."

# Debug: Show what input-related modules exist
info "Available input-related modules:"
find "$KMODDIR" -name "*hid*.ko*" -o -name "*input*.ko*" -o -name "*usb*.ko*" | grep -E "(hid|input|keyboard|mouse|serio)" | sort | head -20

# Define module search paths - these are the likely locations
declare -A module_paths=(
  ["usbhid"]="kernel/drivers/hid"
  ["hid-generic"]="kernel/drivers/hid"
  ["xhci_hcd"]="kernel/drivers/usb/host"
  ["ehci_hcd"]="kernel/drivers/usb/host"
  ["ohci_hcd"]="kernel/drivers/usb/host"
  ["atkbd"]="kernel/drivers/input/keyboard"
  ["psmouse"]="kernel/drivers/input/mouse"
  ["i8042"]="kernel/drivers/input/serio"
  ["evdev"]="kernel/drivers/input"
)

# Copy input modules
for module in usbhid hid-generic xhci_hcd ehci_hcd ohci_hcd atkbd psmouse i8042 evdev; do
  # Try specific path first
  if [[ -n "${module_paths[$module]:-}" ]]; then
    module_path="$KMODDIR/${module_paths[$module]}/${module}.ko.zst"
    if [[ ! -f "$module_path" ]]; then
      module_path="$KMODDIR/${module_paths[$module]}/${module}.ko"
    fi
  fi
  
  # If not found, search everywhere
  if [[ ! -f "$module_path" ]]; then
    module_path=$(find "$KMODDIR" -name "${module}.ko*" -type f | head -1)
  fi
  
  if [[ -f "$module_path" ]]; then
    cp "$module_path" initramfs/lib/
    if [[ "$module_path" == *.zst ]]; then
      zstd -d "initramfs/lib/$(basename "$module_path")" -o "initramfs/lib/${module}.ko"
      rm "initramfs/lib/$(basename "$module_path")"
    fi
    success "Copied $module from $(basename "$(dirname "$module_path")")"
  else
    warn "$module not found - searching with modinfo..."
    # Try to find with modinfo (if available)
    if command -v modinfo >/dev/null 2>&1; then
      modinfo_path=$(modinfo -n "$module" 2>/dev/null | head -1)
      if [[ -f "$modinfo_path" ]]; then
        cp "$modinfo_path" initramfs/lib/
        if [[ "$modinfo_path" == *.zst ]]; then
          zstd -d "initramfs/lib/$(basename "$modinfo_path")" -o "initramfs/lib/${module}.ko"
          rm "initramfs/lib/$(basename "$modinfo_path")"
        fi
        success "Copied $module via modinfo"
      else
        error "$module not found anywhere"
      fi
    else
      error "$module not found and modinfo not available"
    fi
  fi
done

# Copy module dependency files
cp "$KMODDIR/modules.dep" initramfs/lib/modules/6.15.4-arch2-1/
cp "$KMODDIR/modules.dep.bin" initramfs/lib/modules/6.15.4-arch2-1/
cp "$KMODDIR/modules.alias" initramfs/lib/modules/6.15.4-arch2-1/

info "Copying kernel modules for vfat/fat support..."
mkdir -p initramfs/lib/

# Copy modules
cp "$KMODDIR/kernel/fs/fat/fat.ko.zst" initramfs/lib/ || cp "$KMODDIR/kernel/fs/fat/fat.ko" initramfs/lib/
cp "$KMODDIR/kernel/fs/fat/vfat.ko.zst" initramfs/lib/ || cp "$KMODDIR/kernel/fs/fat/vfat.ko" initramfs/lib/
cp "$KMODDIR/kernel/fs/nls/nls_iso8859-1.ko.zst" initramfs/lib/ || cp "$KMODDIR/kernel/fs/nls/nls_iso8859-1.ko" initramfs/lib/

zstd -d initramfs/lib/fat.ko.zst -o initramfs/lib/fat.ko
zstd -d initramfs/lib/vfat.ko.zst -o initramfs/lib/vfat.ko
zstd -d initramfs/lib/nls_iso8859-1.ko.zst -o initramfs/lib/nls_iso8859-1.ko

rm initramfs/lib/*.ko.zst

info "Creating symbolic links for busybox commands..."
for cmd in sh mount mkdir echo ls find cat modprobe insmod; do
  ln -sf busybox "initramfs/bin/$cmd"
done

info "Copying lsblk utility..."
cp /usr/bin/lsblk initramfs/bin/
ldd /usr/bin/lsblk | awk '{print $3}' | grep -E '^/' | while read -r lib; do
  dest="initramfs${lib}"
  mkdir -p "$(dirname "$dest")"
  cp -v "$lib" "$dest"
done

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

info "Creating input device nodes..."
mkdir -p initramfs/dev/input

if [[ ! -e initramfs/dev/input/event0 ]]; then
  sudo mknod -m 0600 initramfs/dev/input/event0 c 13 64
  success "Created /dev/input/event0 node (keyboard)"
fi

if [[ ! -e initramfs/dev/input/event1 ]]; then
  sudo mknod -m 0600 initramfs/dev/input/event1 c 13 65
  success "Created /dev/input/event1 node (mouse)"
fi

if [[ ! -e initramfs/dev/input/mice ]]; then
  sudo mknod -m 0600 initramfs/dev/input/mice c 13 63
  success "Created /dev/input/mice node"
fi

# Add more input event nodes (some systems may need them)
for i in {2..9}; do
  if [[ ! -e initramfs/dev/input/event$i ]]; then
    sudo mknod -m 0600 initramfs/dev/input/event$i c 13 $((64 + i))
  fi
done

info "Copying keyboard layouts..."
if [[ -d /usr/share/X11/xkb ]]; then
  mkdir -p initramfs/usr/share/X11
  cp -r /usr/share/X11/xkb initramfs/usr/share/X11/
  success "Copied /usr/share/X11/xkb"
else
  warn "/usr/share/X11/xkb not found on host"
fi

info "Copying QtQuick Effects plugin and dependencies..."
mkdir -p initramfs/usr/lib/qt6/qml/QtQuick/Effects
cp /usr/lib/qt6/qml/QtQuick/Effects/libeffectsplugin.so initramfs/usr/lib/qt6/qml/QtQuick/Effects/
ldd /usr/lib/qt6/qml/QtQuick/Effects/libeffectsplugin.so | awk '{print $3}' | grep -E '^/' | while read -r lib; do
  dest="initramfs${lib}"
  mkdir -p "$(dirname "$dest")"
  cp -v "$lib" "$dest"
done

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
mkdir -p initramfs/usr/lib/qt6/plugins/generic/
mkdir -p initramfs/usr/lib/

# List of plugins to copy
inputPlugins=(
  libqevdevkeyboardplugin.so
  libqevdevmouseplugin.so
  libqevdevtabletplugin.so
  libqevdevtouchplugin.so
  libqlibinputplugin.so
  libqtslibplugin.so
  libqtuiotouchplugin.so
)

# Source and destination paths
src_dir="/usr/lib/qt6/plugins/generic"
dst_dir="initramfs/usr/lib/qt6/plugins/generic"
lib_dst="initramfs/usr/lib"

info "Copying input plugins..."
for plugin in "${inputPlugins[@]}"; do
  plugin_src="$src_dir/$plugin"
  plugin_dst="$dst_dir/$plugin"

  if [[ -f "$plugin_src" ]]; then
    cp "$plugin_src" "$plugin_dst"
    echo "Copied $plugin"

    # Get dependencies via ldd and copy them
    echo "  ↳ Finding dependencies for $plugin..."
    ldd "$plugin_src" | grep "=> /" | awk '{print $3}' | while read -r lib; do
      if [[ -f "$lib" ]]; then
        lib_basename=$(basename "$lib")
        lib_realpath=$(realpath "$lib")
        lib_target="$lib_dst/$lib_basename"

        # Copy actual library file
        if [[ ! -f "$lib_dst/$(basename "$lib_realpath")" ]]; then
          cp "$lib_realpath" "$lib_dst/"
          echo "    • Copied $(basename "$lib_realpath")"
        fi
      fi
    done

  else
    echo "Warning: $plugin not found in $src_dir"
  fi
done

ldd /usr/lib/qt6/plugins/generic/libqlibinputplugin.so | awk '{print $3}' | grep -E '^/' | while read -r lib; do
  dest="initramfs${lib}"
  mkdir -p "$(dirname "$dest")"
  cp -u "$lib" "$dest"
done

success "Input plugins and their dependencies copied."

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
echo "quiet init=/init console=ttyS0,115200n8 LANG=C.UTF-8 LC_ALL=C.UTF-8" > cmdline.txt

info "Creating unified EFI binary..."
objcopy \
  --add-section .osrel=/etc/os-release --change-section-vma .osrel=0x14DFA0000 \
  --add-section .cmdline=cmdline.txt --change-section-vma .cmdline=0x14DFB0000 \
  --add-section .linux="$KERNEL_IMAGE" --change-section-vma .linux=0x150000000 \
  --add-section .initrd="$INITRAMFS_IMG" --change-section-vma .initrd=0x151000000 \
  "$EFI_STUB" bootx64.efi

info "Creating 256MB disk image..."
dd if=/dev/zero of="$OUTPUT_IMG" bs=1M count=180 status=progress

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