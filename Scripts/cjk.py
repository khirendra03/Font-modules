#!/usr/bin/env python3
"""
By MFFM
This script subsets every .ttf font in the current directory by removing
codepoints that belong to any of the following Unicode ranges:
  - Korean: Hangul Jamo, Hangul Compatibility Jamo, Hangul Syllables
  - Chinese: CJK Unified Ideographs and Extension A
  - Japanese: Hiragana, Katakana, Katakana Phonetic Extensions, Halfwidth Katakana
  - Emoji and related symbols (a few common blocks)
  - Private Use Areas (BMP and Supplementary)
This helps prevent glyphs (e.g. emoji) from overriding NotoEmoji and removes
Korean/Chinese/Japanese characters as well as any custom or private use glyphs.
The output font is saved with a "_subset" tag appended to the original filename.
"""

import glob
import os
from fontTools.ttLib import TTFont
from fontTools import subset

# Define Unicode ranges to exclude:
# Each tuple is (start, end) inclusive.
UNWANTED_RANGES = [
    # Korean ranges
    (0x1100, 0x11FF),   # Hangul Jamo
    (0x3130, 0x318F),   # Hangul Compatibility Jamo
    (0xAC00, 0xD7A3),   # Hangul Syllables

    # Chinese (and many Japanese Kanji) ranges
    (0x3400, 0x4DBF),   # CJK Unified Ideographs Extension A
    (0x4E00, 0x9FFF),   # CJK Unified Ideographs

    # Emoji and symbol ranges
    (0x1F300, 0x1F64F), # Emoji, Emoticons & Misc. Symbols/Pictographs
    (0x1F680, 0x1F6FF), # Transport and Map Symbols (emoji)
    (0x1F900, 0x1F9FF), # Supplemental Symbols and Pictographs (emoji)
    (0x2600, 0x26FF),   # Miscellaneous Symbols (some used as emoji)
    (0x2700, 0x27BF),   # Dingbats

    # Japanese ranges
    (0x3040, 0x309F),   # Hiragana
    (0x30A0, 0x30FF),   # Katakana
    (0x31F0, 0x31FF),   # Katakana Phonetic Extensions
    (0xFF65, 0xFF9F),   # Halfwidth Katakana

    # Private Use Areas
    (0xE000, 0xF8FF),     # Private Use Area (BMP)
    (0xF0000, 0xFFFFD),   # Supplementary Private Use Area-A
    (0x100000, 0x10FFFD), # Supplementary Private Use Area-B
]

def should_exclude(cp):
    """
    Return True if the Unicode codepoint should be excluded
    (i.e. is in any of the unwanted ranges).
    """
    for start, end in UNWANTED_RANGES:
        if start <= cp <= end:
            return True
    return False

def process_font(font_path):
    print(f"Processing {font_path}...")
    
    # Open the font.
    font = TTFont(font_path)
    cmap = font.getBestCmap()
    if cmap is None:
        print(f"Warning: {font_path} does not have a usable cmap. Skipping.")
        return

    # Build a list of Unicode codepoints that we wish to keep.
    allowed_codepoints = [cp for cp in cmap.keys() if not should_exclude(cp)]
    if not allowed_codepoints:
        print(f"No allowed codepoints found in {font_path}. Skipping.")
        return

    print(f"Keeping {len(allowed_codepoints)} out of {len(cmap)} codepoints.")

    # Set up the subset options.
    options = subset.Options()
    options.flavor = "ttf"  # ensure output as TTF
    options.desubroutinize = True

    # Create a subsetter, load it with allowed Unicode codepoints, and perform the subsetting.
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=allowed_codepoints)
    subsetter.subset(font)

    # Create an output filename by appending a tag before the extension.
    base, ext = os.path.splitext(font_path)
    out_path = f"{base}_subset{ext}"
    font.save(out_path)
    print(f"Saved subset font to {out_path}")

def main():
    # Find all .ttf files in the current directory.
    ttf_files = glob.glob("*.ttf")
    if not ttf_files:
        print("No TTF files found in the current directory.")
        return

    for font_path in ttf_files:
        try:
            process_font(font_path)
        except Exception as e:
            print(f"Error processing {font_path}: {e}")

if __name__ == "__main__":
    main()
