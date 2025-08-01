#!/usr/bin/env python3
"""
By MFFM
This script scales the glyph outlines and metrics of every TTF file in the current directory.
It supports fonts with TrueType outlines (glyf/gvar) as well as fonts using CFF2 outlines (and cvar).
After processing each font, it moves the original file into a backup_ttf folder and replaces it with the scaled version.
"""

import os
import glob
import shutil
import argparse
from datetime import datetime
from fontTools.ttLib import TTFont
from fontTools.pens.transformPen import TransformPen

def scale_glyf_font(font, scale):
    """
    For fonts with a 'glyf' table (TrueType outlines), redraw every glyph using a TransformPen.
    """
    from fontTools.pens.ttGlyphPen import TTGlyphPen
    glyphSet = font.getGlyphSet()
    glyfTable = font["glyf"]
    # Use a 2D transform matrix: (scale, 0, 0, scale, 0, 0)
    matrix = (scale, 0, 0, scale, 0, 0)
    for glyphName in font.getGlyphOrder():
        glyph = glyphSet[glyphName]
        pen = TTGlyphPen(glyphSet)
        tpen = TransformPen(pen, matrix)
        try:
            glyph.draw(tpen)
        except Exception as e:
            print(f"Error drawing glyph '{glyphName}': {e}")
            continue
        newGlyph = pen.glyph()
        glyfTable[glyphName] = newGlyph

def scale_cff2_font(font, scale):
    """
    For fonts with a 'CFF2' table (CFF2 outlines, common in some variable fonts),
    rebuild the charstrings using a T2CharString pen wrapped by a TransformPen.
    """
    from fontTools.pens.t2CharStringPen import T2CharStringPen
    glyphSet = font.getGlyphSet()
    cff2 = font["CFF2"]
    # Get the top dict from the CFF2 table
    topDict = cff2.cff.topDictIndex[0]
    charStrings = topDict.CharStrings
    newCharStrings = {}
    matrix = (scale, 0, 0, scale, 0, 0)
    for glyphName in list(charStrings.charStrings.keys()):
        glyph = glyphSet[glyphName]
        pen = T2CharStringPen(glyphSet)
        tpen = TransformPen(pen, matrix)
        try:
            glyph.draw(tpen)
        except Exception as e:
            print(f"Error drawing glyph '{glyphName}' in CFF2: {e}")
            continue
        newCharString = pen.getCharString()
        newCharStrings[glyphName] = newCharString
    # Replace the existing charstrings with the new (scaled) ones
    charStrings.charStrings = newCharStrings

def scale_variations(variations, scale):
    """
    For variation data (in gvar or cvar), scale each delta by the given factor.
    The 'variations' parameter is a dictionary mapping glyph names to a list of TupleVariation objects.
    """
    for glyphName, varList in variations.items():
        for var in varList:
            if var.delta is not None:
                var.delta = [(dx * scale, dy * scale) for dx, dy in var.delta]

def set_default_weight_to_regular(font):
    """
    If the font has a 'wght' axis in its 'fvar' table, set its default value to 400 (Regular).
    """
    if "fvar" in font:
        for axis in font["fvar"].axes:
            if axis.axisTag == "wght":
                axis.defaultValue = 400
                print("Set default weight to 400 (Regular).")
                break

def scale_metrics(font, scale):
    """
    Scale various metrics so that (for example) the advance widths, sidebearings,
    bounding box values, and common vertical metrics are multiplied by the scale factor.
    """
    # Scale horizontal metrics (hmtx)
    hmtx = font["hmtx"].metrics
    for glyphName, (width, lsb) in hmtx.items():
        hmtx[glyphName] = (int(round(width * scale)), int(round(lsb * scale)))

    # Scale the global bounding box in the head table
    head = font["head"]
    head.xMin = int(round(head.xMin * scale))
    head.yMin = int(round(head.yMin * scale))
    head.xMax = int(round(head.xMax * scale))
    head.yMax = int(round(head.yMax * scale))

    # Scale hhea metrics if present
    if "hhea" in font:
        hhea = font["hhea"]
        hhea.ascender = int(round(hhea.ascender * scale))
        hhea.descender = int(round(hhea.descender * scale))
        hhea.lineGap = int(round(hhea.lineGap * scale))

def main():
    """
    Main function to run the scaling script.
    - Parses command-line arguments for scaling and setting default weight.
    - Finds all TTF files in the current directory.
    - Backs up original fonts to a timestamped directory.
    - Applies scaling and/or sets default weight.
    - Saves the modified fonts.
    """
    parser = argparse.ArgumentParser(description="Scale fonts and/or set default weight to Regular.")
    parser.add_argument("--scale-factor", type=float, help="The scaling factor (e.g., 0.5 for 50%%).")
    parser.add_argument("--set-weight-regular", action="store_true", help="Set the default weight to 400 (Regular).")
    args = parser.parse_args()

    if not args.scale_factor and not args.set_weight_regular:
        print("No action specified. Use --scale-factor or --set-weight-regular.")
        return

    # Create a timestamped backup directory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = f"backup_ttf_{timestamp}"
    os.makedirs(backup_dir)
    print(f"Backup directory created: {backup_dir}")

    # Find all TTF files in the current directory
    font_files = glob.glob("*.ttf")
    if not font_files:
        print("No .ttf files found in the current directory.")
        return

    for font_path in font_files:
        backup_path = os.path.join(backup_dir, os.path.basename(font_path))
        try:
            print(f"Processing {font_path}...")
            font = TTFont(font_path)

            # Move the original font to the backup directory
            shutil.move(font_path, backup_path)

            modified = False
            if args.scale_factor:
                scale_factor = args.scale_factor
                print(f"Scaling by factor {scale_factor}...")
                # Scale outlines based on font type
                if "glyf" in font:
                    scale_glyf_font(font, scale_factor)
                elif "CFF2" in font:
                    scale_cff2_font(font, scale_factor)
                else:
                    print(f"Warning: {font_path} has neither 'glyf' nor 'CFF2' table. Skipping outline scaling.")

                # Scale metrics
                scale_metrics(font, scale_factor)

                # Scale variations if present
                if "gvar" in font:
                    scale_variations(font["gvar"].variations, scale_factor)
                if "cvar" in font:
                    scale_variations(font["cvar"].variations, scale_factor)
                modified = True

            if args.set_weight_regular:
                print("Setting default weight to 400...")
                set_default_weight_to_regular(font)
                modified = True

            # Save the modified font back to the original path
            if modified:
                font.save(font_path)
                print(f"Successfully processed and saved {font_path}")
            else:
                # If no modifications were made, move the original font back
                shutil.move(backup_path, font_path)
                print(f"No operations performed on {font_path}, restored original.")


        except Exception as e:
            print(f"Error processing {font_path}: {e}")
            # If an error occurs, try to restore the original font from backup
            if os.path.exists(backup_path) and not os.path.exists(font_path):
                shutil.move(backup_path, font_path)
                print(f"Restored original font: {font_path}")

if __name__ == "__main__":
    main()
