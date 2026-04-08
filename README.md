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

You can easily create your own font module using the provided automation script.

1. Prepare your font files (`.ttf` or `.otf`) in a folder.
2. Run the creation script from the root of the repository:
   ```bash
   bash Scripts/create_module.sh --name "MyFont" --version "1.0" --fonts "/path/to/my/fonts" --changelog "Initial release"
   ```
3. The script will:
   - Automatically rename fonts to OMF conventions (using `Scripts/rename_fonts.sh`).
   - Package the module using the `Template/` folder.
   - Update `update.json` and `changelog.md` in the module's directory.
4. Your flashable ZIP will be located in `Modules/MyFont/`.

## Repository Structure
```bash
Font-modules/
├── Modules/       # Ready-to-use font modules
├── Template/      # OMF-based template for creating modules
├── Extensions/    # Additional add-ons (Serif, Monospace, Devanagari)
├── Scripts/       # Helper scripts for renaming and module creation
└── README.md      # This file
```

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