# Magisk flashable Font modules
[![GitHub release](https://img.shields.io/github/v/release/khirendra03/Font-modules)](https://github.com/khirendra03/Font-modules/releases)
[![License](https://img.shields.io/github/license/khirendra03/Font-modules)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/khirendra03/Font-modules/total)](https://github.com/khirendra03/Font-modules/releases)
[![Issues](https://img.shields.io/github/issues/khirendra03/Font-modules)](https://github.com/khirendra03/Font-modules/issues)
[![Last Commit](https://img.shields.io/github/last-commit/khirendra03/Font-modules)](https://github.com/khirendra03/Font-modules/commits/main)

 **Magisk-flashable font modules** based on the **Oh My Font (OMF) template**.  
Easily change your Android system fonts on devices running latest Android, with optional bold styling support.

---

## ✨ Features
- 📱 Works on Android
- 🎨 Multiple font styles available
- 🖋 Supports **bold text styling**
- ⚙️ Based on the **OMF Magisk template**
- 🛠 Simple install — just flash in Magisk Manager

---

## Installation

### 1. Download
- Get the latest module ZIP from the **[inside font folder](https://github.com/khirendra03/Font-modules/modules)** page  
  or from [SourceForge](https://sourceforge.net/projects/font-modules/files/Modules/).

### 2. Flash via Magisk Manager
1. Open **Magisk Manager**
2. Go to **Modules → Install from storage**
3. Select the downloaded `.zip` file
4. Reboot your device

---

## Creating Your Own Font Module

You can easily make your own font module using the **provided template**.

1. Download the `Template/` folder from this repo
2. Replace the font files inside `system/fonts/` with your custom `.ttf` or `.otf` fonts
3. Edit the `module.prop` file to set:
   ```properties
   id=my.custom.font
   name=My Custom Font
   version=1.0
   versionCode=1
   author=Your Name
   description=Custom font module using OMF template
4. Zip the entire directory and you're ready to go.

## Repository Structure
bash
Copy code
Font-modules/
├── Modules/       # Ready-to-use font modules
├── Template/      # Base template for creating modules
├── Scripts/       # Optional helper scripts
├── Extensions/    # Additional add-ons
└── README.md      # This file

## Contribution Guidelines
- If you want to contribute to the project, you can submit new modules, report issues, or suggest improvements.
- To submit a new module, please create a pull request on GitHub.
- To report an issue or suggest an improvement, please open an issue on GitHub.
- You can also join our [Telegram group](https://t.me/MFFMDisc) for support and troubleshooting.

## Note
- All old modules will be deleted and only the latest modules will be available in this repository. You can find all old and new modules on [SourceForge](https://sourceforge.net/projects/font-modules/files/)
- you can find all old & new modules [here](https://sourceforge.net/projects/font-modules/files/)

## Important links
- [Support](https://t.me/MFFMDisc) - Join our Telegram group for support and troubleshooting
- [OTL feature of a font](https://t.me/marcellasne_zero) - Learn more about the OTL feature of a font
- [Extensions](https://gitlab.com/nongthaihoang/oh_my_font#extensions) - Learn more about available extensions for OMF

## Credits
[Oh My Font](https://gitlab.com/nongthaihoang/oh_my_font) by [Nông Thái Hoàng](https://gitlab.com/nongthaihoang)

---

*Disclaimer: Use this module at your own risk. The developer is not responsible for any damage caused to your device.*