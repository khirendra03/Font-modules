#!/bin/bash

# An intelligent script to rename font files based on the conventions
# in README.md.
#
# Features:
#   - Supports all font families (sans-serif, serif, monospace, etc.).
#   - Dry run mode to preview changes without executing them.
#   - Revert mode to undo renames using a log file.
#
# Usage:
#   bash rename_fonts.sh          # Normal rename operation
#   bash rename_fonts.sh --dry-run  # See what the script would do
#   bash rename_fonts.sh --revert   # Undo the last rename operation

# --- Configuration ---
DRY_RUN=false
REVERT=false
LOG_FILE=".rename_log.csv"

# --- Argument Parsing ---
if [ "$1" == "--dry-run" ] || [ "$1" == "-n" ]; then
    DRY_RUN=true
    echo "Dry Run mode enabled. No files will be changed."
fi

if [ "$1" == "--revert" ]; then
    REVERT=true
fi

# --- Main Logic ---
# Enter the fonts directory
cd fonts || { echo "Error: 'fonts' directory not found."; exit 1; }

# --- Revert Functionality ---
if [ "$REVERT" = true ]; then
    if [ ! -f "$LOG_FILE" ]; then
        echo "Error: Log file '$LOG_FILE' not found. Cannot revert."
        exit 1
    fi
    echo "Reverting renames..."
    # Read file in reverse to handle multiple renames of the same file correctly
    tac "$LOG_FILE" | while IFS=, read -r original new; do
        if [ -f "$new" ]; then
            echo "Reverting '$new' to '$original'"
            mv "$new" "$original"
        else
            # This can happen if a file was manually deleted after renaming
            echo "Warning: File '$new' not found. Cannot revert to '$original'."
        fi
    done
    # Clean up the log file after a successful revert
    rm "$LOG_FILE"
    echo "Revert complete."
    cd ..
    exit 0
fi

# --- Renaming Functionality ---
# Create log file if it doesn\'t exist, but only if we are not in dry run mode
if [ "$DRY_RUN" = false ] && [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

echo "Starting font renaming process..."

for fontfile in *.ttf; do
    # Skip files that already look like they have been renamed
    if [[ "$fontfile" =~ ^[a-z]{2,4}\.ttf$ ]]; then
        continue
    fi

    lower_fontfile=$(echo "$fontfile" | tr '[:upper:]' '[:lower:]')
    new_name=""
    style_prefix=""
    
    # 1. Determine Font Family and Style Prefix
    # Check for serif-monospace first as it contains "serif" and "mono"
    if [[ "$lower_fontfile" == *"serifmono"* || "$lower_fontfile" == *"serif-mono"* ]]; then
        family="Serif Monospace"
        if [[ "$lower_fontfile" == *"italic"* ]]; then style_prefix="p"; else style_prefix="o"; fi
    elif [[ "$lower_fontfile" == *"mono"* ]]; then
        family="Monospace"
        if [[ "$lower_fontfile" == *"italic"* ]]; then style_prefix="n"; else style_prefix="m"; fi
    elif [[ "$lower_fontfile" == *"serif"* ]]; then
        family="Serif"
        if [[ "$lower_fontfile" == *"italic"* ]]; then style_prefix="t"; else style_prefix="s"; fi
    else # Default to sans-serif
        family="Sans Serif"
        if [[ "$lower_fontfile" == *"condenseditalic"* || "$lower_fontfile" == *"condensed-italic"* ]]; then
            style_prefix="d"
        elif [[ "$lower_fontfile" == *"italic"* ]]; then
            style_prefix="i"
        elif [[ "$lower_fontfile" == *"condensed"* ]]; then
            style_prefix="c"
        else
            style_prefix="u"
        fi
    fi

    # 2. Determine Font Weight Suffix
    # The order is important to prevent "semibold" from being matched as "bold".
    weight_suffix=""
    if [[ "$lower_fontfile" == *"semibold"* || "$lower_fontfile" == *"semi-bold"* ]]; then
        weight_suffix="sb"
    elif [[ "$lower_fontfile" == *"extrabold"* || "$lower_fontfile" == *"extra-bold"* ]]; then
        weight_suffix="eb"
    elif [[ "$lower_fontfile" == *"black"* ]]; then
        weight_suffix="bl"
    elif [[ "$lower_fontfile" == *"bold"* ]]; then
        weight_suffix="b"
    elif [[ "$lower_fontfile" == *"medium"* ]]; then
        weight_suffix="m"
    elif [[ "$lower_fontfile" == *"regular"* ]]; then
        weight_suffix="r"
    elif [[ "$lower_fontfile" == *"extralight"* || "$lower_fontfile" == *"extra-light"* ]]; then
        weight_suffix="el"
    elif [[ "$lower_fontfile" == *"light"* ]]; then
        weight_suffix="l"
    elif [[ "$lower_fontfile" == *"thin"* ]]; then
        weight_suffix="t"
    fi

    # 3. Construct New Name and Execute/Log
    if [ -n "$style_prefix" ] && [ -n "$weight_suffix" ]; then
        new_name="${style_prefix}${weight_suffix}.ttf"
        
        if [ -f "$new_name" ]; then
            echo "Warning: Target file '$new_name' already exists. Skipping rename of '$fontfile'."
        else
            if [ "$DRY_RUN" = true ]; then
                echo "DRY RUN: Would rename '$fontfile' to '$new_name' (Family: $family)"
            else
                echo "Renaming '$fontfile' to '$new_name'"
                mv "$fontfile" "$new_name"
                # Log the change for future reversion
                echo "$fontfile,$new_name" >> "$LOG_FILE"
            fi
        fi
    else
        echo "Warning: Could not determine new name for '$fontfile'. It has been left unchanged."
    fi
done

cd ..
echo "Font renaming process complete."
