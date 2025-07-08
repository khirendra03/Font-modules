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
