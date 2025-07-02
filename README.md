# AetherBoot ⚡

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-UEFI-blue.svg)](https://uefi.org/)
[![Language](https://img.shields.io/badge/Language-C%2B%2B20-orange.svg)](https://isocpp.org/)
[![Framework](https://img.shields.io/badge/Framework-Qt6%2FQML-green.svg)](https://www.qt.io/)
[![Arch Linux](https://img.shields.io/badge/Built%20for-Arch%20Linux-1793d1.svg)](https://archlinux.org/)
![aetherboot_logo](https://github.com/user-attachments/assets/30b76030-798e-4551-b2b7-3da594697ddb)
<svg viewBox="0 0 300 120" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient id="aetherGradient" x1="0%" y1="0%" x2="100%" y2="100%">
<stop offset="0%" style="stop-color:#4F46E5;stop-opacity:1" />
<stop offset="50%" style="stop-color:#7C3AED;stop-opacity:1" />
<stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
</linearGradient>
<linearGradient id="bootGradient" x1="0%" y1="0%" x2="100%" y2="0%">
<stop offset="0%" style="stop-color:#10B981;stop-opacity:1" />
<stop offset="100%" style="stop-color:#06B6D4;stop-opacity:1" />
</linearGradient>
<filter id="glow">
<feGaussianBlur stdDeviation="3" result="coloredBlur"/>
<feMerge>
<feMergeNode in="coloredBlur"/>
<feMergeNode in="SourceGraphic"/>
</feMerge>
</filter>
<radialGradient id="starGlow" cx="50%" cy="50%" r="50%">
<stop offset="0%" style="stop-color:#FFFFFF;stop-opacity:0.8" />
<stop offset="100%" style="stop-color:#FFFFFF;stop-opacity:0" />
</radialGradient>
</defs>
<circle cx="60" cy="60" r="45" fill="url(#aetherGradient)" opacity="0.1" stroke="url(#aetherGradient)" stroke-width="1" fill-opacity="0.05"/>
<g transform="translate(60,60)">
<circle cx="0" cy="0" r="18" fill="none" stroke="url(#bootGradient)" stroke-width="3" opacity="0.8"/>
<line x1="0" y1="-25" x2="0" y2="-8" stroke="url(#bootGradient)" stroke-width="3" stroke-linecap="round"/>
<circle cx="0" cy="0" r="28" fill="none" stroke="url(#aetherGradient)" stroke-width="1.5" opacity="0.4" stroke-dasharray="4,4">
<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0" to="360" dur="20s" repeatCount="indefinite"/>
</circle>
<circle cx="0" cy="0" r="35" fill="none" stroke="url(#aetherGradient)" stroke-width="1" opacity="0.3" stroke-dasharray="2,6">
<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="360" to="0" dur="30s" repeatCount="indefinite"/>
</circle>
</g>
<circle cx="25" cy="25" r="1.5" fill="#FFFFFF" opacity="0.7">
<animate attributeName="opacity" values="0.7;0.3;0.7" dur="3s" repeatCount="indefinite"/>
</circle>
<circle cx="90" cy="30" r="1" fill="#FFFFFF" opacity="0.5">
<animate attributeName="opacity" values="0.5;0.9;0.5" dur="4s" repeatCount="indefinite"/>
</circle>
<circle cx="35" cy="90" r="1.2" fill="#FFFFFF" opacity="0.6">
<animate attributeName="opacity" values="0.6;0.2;0.6" dur="2.5s" repeatCount="indefinite"/>
</circle>
<circle cx="85" cy="85" r="0.8" fill="#FFFFFF" opacity="0.4">
<animate attributeName="opacity" values="0.4;0.8;0.4" dur="5s" repeatCount="indefinite"/>
</circle>
</svg>

> 🚀 A modern graphical UEFI boot manager for Arch Linux and other operating systems

AetherBoot brings elegant boot management to your UEFI system with a sleek Qt6/QML interface. It automatically discovers all EFI System Partitions (ESP) across drives and provides intuitive boot entry selection with support for both traditional EFI chainloading and fast Linux boot via kexec.

---

## ⚠️ Warning (PLEASE READ)

AetherBoot is not production ready and you should not install this on your machine unless you know what you're doing, there is still a lot of work needed to get to that point, please don't replace your current bootloader with this half baked project (for now).

---

## 📝 Features

- Add Mouse Support
- Reduce .img size
- General cleanup
- Improvements
- Responsiveness

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
