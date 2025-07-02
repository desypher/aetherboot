# AetherBoot ⚡

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-UEFI-blue.svg)](https://uefi.org/)
[![Language](https://img.shields.io/badge/Language-C%2B%2B20-orange.svg)](https://isocpp.org/)
[![Framework](https://img.shields.io/badge/Framework-Qt6%2FQML-green.svg)](https://www.qt.io/)
[![Arch Linux](https://img.shields.io/badge/Built%20for-Arch%20Linux-1793d1.svg)](https://archlinux.org/)

> 🚀 A modern graphical UEFI boot manager for Arch Linux and other operating systems

AetherBoot brings elegant boot management to your UEFI system with a sleek Qt6/QML interface. It automatically discovers all EFI System Partitions (ESP) across drives and provides intuitive boot entry selection with support for both traditional EFI chainloading and fast Linux boot via kexec.

---

## ✨ Features

🔍 **Automatic EFI boot entry detection** across all connected drives  
🎨 **Clean and intuitive Qt6/QML user interface** with keyboard and mouse support  
⚡ **Supports launching EFI binaries** with chainloading via `efibootmgr` or fast Linux boots via `kexec`  
🎭 **Easily customizable and themeable UI** for personalized boot experience  
🏗️ **Designed for seamless integration** with Arch Linux initramfs environments  
💾 **Bootable as a UEFI binary** or Linux initramfs application  

---

## 🚀 Getting Started

### 📋 Prerequisites

- 🐧 **Arch Linux** or compatible distribution
- 📦 **Qt6 development libraries** (`qt6-base`, `qt6-quickcontrols2`)
- 🛠️ **System tools**: `efibootmgr`, `kexec-tools`
- 💻 **UEFI system** with EFI variables support (`/sys/firmware/efi/efivars` mounted)
- 🔨 **CMake 3.18** or newer
- ⚙️ **GCC 10+** or Clang with C++20 support

### 🏗️ Build Instructions

```bash
# Clone the repository
git clone https://github.com/desypher/aetherboot.git
cd aetherboot

# Create build directory
mkdir build && cd build

# Configure and build
cmake ..
make
```

### 📦 Installation

```bash
# Install to system (requires root)
sudo make install

# Or create a package (Arch Linux)
makepkg -si
```

---

## 🎯 Usage

### As UEFI Application
1. Copy the built binary to your ESP: `/boot/efi/EFI/aetherboot/`
2. Register with efibootmgr or access via UEFI boot menu

### As Initramfs Tool
1. Install to initramfs hooks directory
2. Rebuild initramfs with `mkinitcpio`
3. Boot from recovery or custom initramfs

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔄 Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Qt Project for the excellent Qt6/QML framework
- Arch Linux community for inspiration and testing
- UEFI specification contributors

---

<div align="center">

**Made with ❤️ for the Linux community**

[⭐ Star this project](https://github.com/desypher/aetherboot) • [🐛 Report Bug](https://github.com/desypher/aetherboot/issues) • [💡 Request Feature](https://github.com/desypher/aetherboot/issues)

</div>
