# AetherBoot

AetherBoot is a modern graphical UEFI boot manager for Arch Linux and other operating systems.  
It features a sleek Qt6/QML interface, automatically scans all EFI System Partitions (ESP) across drives, and allows easy boot entry selection.

---

## Features

- **Automatic EFI boot entry detection** across all connected drives
- **Clean and intuitive Qt6/QML user interface** with keyboard and mouse support
- **Supports launching EFI binaries** with chainloading via `efibootmgr` or fast Linux boots via `kexec`
- Easily customizable and themeable UI
- Designed for seamless integration with Arch Linux initramfs environments
- Bootable as a UEFI binary or Linux initramfs application

---

## Getting Started

### Prerequisites

- Arch Linux or compatible distro
- Qt6 development libraries (`qt6-base`, `qt6-quickcontrols2`)
- `efibootmgr`, `kexec-tools`
- UEFI system with EFI variables support (`/sys/firmware/efi/efivars` mounted)
- CMake 3.18 or newer
- GCC 10+ or Clang with C++20 support

### Build

```bash
git clone https://github.com/deypher/aetherboot.git
cd aetherboot
mkdir build && cd build
cmake ..
make
```
