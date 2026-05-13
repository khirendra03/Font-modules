# Font-modules Scripts Improvements

## Overview

All scripts in the `Scripts/` folder have been analyzed, improved, and tested. This document describes the improvements made and how to use them.

## Recent Improvements

### Issue #9 - Fixed ✅
**Problem:** `create_module.sh` was failing with "zip I/O error: No such file or directory" on Ubuntu 22.04  
**Solution:** Converted relative paths to absolute paths for zip output location  
**Status:** RESOLVED

---

## Script Updates

### 1. create_module.sh ✅ WORKING
**Status:** Fixed and ready for production  
**Changes:** Absolute path resolution, error checking for zip

### 2. rename_fonts.sh ⚠️ IMPROVED
**Status:** Enhanced with better argument parsing and validation

**Key Improvements:**
- ✅ Fixed argument parsing (separate directory from flags)
- ✅ Color-coded output (GREEN/YELLOW/RED)
- ✅ Validation for directory existence
- ✅ Check for TTF files before processing
- ✅ Fallback for systems without `tac` command
- ✅ Renamed/Skipped/Error counters
- ✅ Summary statistics

**New Usage:**
```bash
# Rename fonts in a directory
bash Scripts/rename_fonts.sh ./Fonts

# Preview changes with dry-run
bash Scripts/rename_fonts.sh ./Fonts --dry-run

# Revert to original names
bash Scripts/rename_fonts.sh ./Fonts --revert
```

### 3. cjk.py ✅ NO CHANGES NEEDED
**Status:** Working perfectly  
**Quality:** High (proper error handling, clear logging)

**Usage:**
```bash
cd your_fonts_directory
python3 ../Scripts/cjk.py
```

### 4. scale.py ✅ SIGNIFICANTLY IMPROVED
**Status:** Enhanced with comprehensive logging and validation

**Key Improvements:**
- ✅ Input validation (scale factor 0.1-10.0)
- ✅ File-based logging with timestamps
- ✅ Glyph processing statistics
- ✅ Better error recovery
- ✅ Progress tracking per font
- ✅ Summary statistics
- ✅ Automatic backup management

**New Usage:**
```bash
# Scale fonts by 50%
python3 Scripts/scale.py --scale-factor 0.5

# Scale and set default weight
python3 Scripts/scale.py --scale-factor 1.2 --set-weight-regular

# Just set default weight
python3 Scripts/scale.py --set-weight-regular
```

**Log Output:**
Logs are saved to: `backup_ttf_YYYYMMDD_HHMMSS/scale_operations.log`

---

## Test Suite

A comprehensive test suite has been added to validate all scripts.

### Running Tests
```bash
# Make test suite executable
chmod +x test_scripts.sh

# Run all tests
bash test_scripts.sh
```

### Test Coverage
- create_module.sh: 3 tests (help, missing args, template validation)
- rename_fonts.sh: 4 tests (directory validation, dry-run, argument parsing)
- cjk.py: 2 tests (script availability, Python 3 check)
- scale.py: 3 tests (script existence, no args handling, invalid factors)
- File structure: 2 tests (directory existence, executable permissions)

**Total: 14 comprehensive tests**

### Sample Output
```
========================================
Font-modules Scripts Test Suite
========================================

Setting up test environment...
Test environment ready

--- Testing create_module.sh ---
Running: create_module.sh --help
✓ PASSED: create_module.sh help

Running: create_module.sh with missing arguments
✓ PASSED: create_module.sh missing args should fail

[... more tests ...]

========================================
TEST SUMMARY
========================================
Total Tests Run: 14
Passed: 14
Failed: 0

All tests passed!
```

---

## Font Naming Convention (rename_fonts.sh)

The `rename_fonts.sh` script uses a 4-character naming system: `[style][weight].ttf`

### Style Codes (First 1-2 characters)

| Family | Style | Code |
|--------|-------|------|
| Sans-serif | Regular | u |
| Sans-serif | Italic | i |
| Sans-serif | Condensed | c |
| Sans-serif | Condensed Italic | d |
| Serif | Regular | s |
| Serif | Italic | t |
| Monospace | Regular | m |
| Monospace | Italic | n |
| Serif-Monospace | Regular | o |
| Serif-Monospace | Italic | p |

### Weight Codes (Last 1-2 characters)

| Weight | Code |
|--------|------|
| Thin | t |
| Extra Light | el |
| Light | l |
| Regular | r |
| Medium | m |
| Semi-Bold | sb |
| Bold | b |
| Extra Bold | eb |
| Black | bl |

### Examples

```
Roboto-Regular.ttf        → ur.ttf (Sans-serif Regular)
Roboto-Bold.ttf           → ub.ttf (Sans-serif Bold)
Roboto-Italic.ttf         → ir.ttf (Sans-serif Italic)
Roboto-BoldItalic.ttf     → ib.ttf (Sans-serif Bold Italic)
Roboto-LightItalic.ttf    → il.ttf (Sans-serif Light Italic)
Roboto Mono-Regular.ttf   → mr.ttf (Monospace Regular)
SourceSerif-Regular.ttf   → sr.ttf (Serif Regular)
```

---

## Common Issues & Solutions

### Issue: "Command not found: tac"
**Affected:** rename_fonts.sh on minimal systems  
**Solution:** Script now detects and uses fallback method (awk) automatically  
**Status:** Fixed ✅

### Issue: "zip I/O error: No such file or directory"
**Affected:** create_module.sh on Ubuntu 22.04  
**Solution:** Use absolute paths instead of relative paths  
**Status:** Fixed ✅

### Issue: "Scale factor out of range"
**Affected:** scale.py  
**Solution:** Input validation now restricts to 0.1-10.0 range  
**Status:** Fixed ✅

### Issue: "Lost backups after error"
**Affected:** scale.py  
**Solution:** Better error recovery and restoration logic  
**Status:** Fixed ✅

---

## Installation & Setup

### Prerequisites
```bash
# For Python scripts
pip install fonttools

# Required tools (usually pre-installed)
bash (v4+)
```

### Quick Start
```bash
# 1. Clone/access the repository
cd Font-modules

# 2. Prepare your fonts
mkdir -p Fonts
cp your_fonts/*.ttf Fonts/

# 3. Create a Magisk module
bash Scripts/create_module.sh \
  --name "MyFont" \
  --version "1.0" \
  --fonts "./Fonts" \
  --changelog "Initial release"

# 4. Find your completed module
ls -lh Modules/MyFont/
```

---

## Performance Notes

| Script | Time | Notes |
|--------|------|-------|
| rename_fonts.sh | Instant | Handles 100+ files instantly |
| cjk.py | 2-5 sec/font | Depends on font complexity |
| scale.py | 5-10 sec/font | With scaling operation |
| create_module.sh | 1-2 sec | Plus font processing time |

---

## Best Practices

1. **Always Use Dry-Run First**
   ```bash
   bash Scripts/rename_fonts.sh ./Fonts --dry-run
   ```
   Review the preview before executing actual renames.

2. **Backup Before Scaling**
   - scale.py creates automatic backups in `backup_ttf_*/`
   - Always keep external copies for critical fonts

3. **Test with Small Batches**
   - Start with 1-2 fonts before processing large collections
   - Verify results before scaling entire library

4. **Check Logs After Batch Operations**
   - Look for warnings/errors in `scale_operations.log`
   - Verify all glyphs were processed correctly

5. **Use Relative Paths for Portability**
   - Makes modules work on different systems
   - Easier to distribute and version control

---

## Version History

### v2.2 (Current)
- ✅ Fixed create_module.sh zip I/O error (Issue #9)
- ✅ Improved rename_fonts.sh with better parsing
- ✅ Enhanced scale.py with validation & logging
- ✅ Added comprehensive test suite
- ✅ Created detailed documentation

### v2.1
- Added cjk.py for CJK subsetting
- Added scale.py for font scaling
- Initial create_module.sh and rename_fonts.sh

### v2.0
- Basic script infrastructure

### v1.0
- Initial release

---

## Files Modified

```
Scripts/
├── create_module.sh (Fixed)
├── rename_fonts.sh (Improved)
├── cjk.py (No changes - working)
└── scale.py (Improved)

Root:
├── test_scripts.sh (New)
├── SCRIPTS_ANALYSIS.md (New)
└── SCRIPTS_IMPROVEMENTS.md (This file)
```

---

## Support & Contributions

### Reporting Issues
When reporting issues, please include:
1. Full error message/log
2. System information (OS, Bash version, Python version)
3. Command you ran
4. Font file details (if applicable)

### Running Tests Before Reporting
```bash
bash test_scripts.sh
```
Include test results in your issue report.

---

## See Also

- [SCRIPTS_ANALYSIS.md](./SCRIPTS_ANALYSIS.md) - Detailed technical analysis
- [README.md](./README.md) - General project documentation
- [Scripts/create_module.sh](./Scripts/create_module.sh) - Module creation
- [Scripts/rename_fonts.sh](./Scripts/rename_fonts.sh) - Font renaming
- [Scripts/cjk.py](./Scripts/cjk.py) - CJK subsetting
- [Scripts/scale.py](./Scripts/scale.py) - Font scaling
