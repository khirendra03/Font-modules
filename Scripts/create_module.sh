#!/bin/bash

# Improved Magisk Font Module Creator (OMF Based)
# Author: khirendra03
# Refined by Gemini CLI

# Default values
AUTHOR="khirendra03"
TEMPLATE_DIR="Template"
MODULES_ROOT="Modules"

# Help message
function show_help {
    echo "Usage: $0 --name <font_name> --version <version> --fonts <path_to_fonts_dir> --changelog <"changelog_message"> [--author <author_name>]"
    echo
    echo "   --name          : Name of the font (e.g., \"Roboto\")."
    echo "   --version       : Version of the module (e.g., \"3.5\")."
    echo "   --fonts         : Path to the directory containing the font files (.ttf or .otf)."
    echo "   --changelog     : A message describing the changes for this version, enclosed in quotes."
    echo "   --author        : (Optional) The name of the module creator. Defaults to '$AUTHOR'."
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) FONT_NAME="$2"; shift ;;
        --version) VERSION="$2"; shift ;;
        --fonts) FONTS_DIR="$2"; shift ;;
        --changelog) CHANGELOG_MSG="$2"; shift ;;
        --author) AUTHOR="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Validate required arguments
if [ -z "$FONT_NAME" ] || [ -z "$VERSION" ] || [ -z "$FONTS_DIR" ] || [ -z "$CHANGELOG_MSG" ]; then
    echo "Error: Missing required arguments."
    show_help
    exit 1
fi

# Validate Template
if [ ! -d "$TEMPLATE_DIR" ] || [ ! -f "$TEMPLATE_DIR/module.prop" ]; then
    echo "Error: Template directory '$TEMPLATE_DIR' is missing or invalid."
    echo "Please ensure the OMF template is downloaded into the '$TEMPLATE_DIR' folder."
    exit 1
fi

# --- Script Execution ---

MODULE_PATH="$MODULES_ROOT/$FONT_NAME"
ZIP_NAME="${FONT_NAME// /_}[OMF].zip"
TEMP_BUILD_DIR=$(mktemp -d)
VERSION_CODE=$(date +%Y%m%d)

echo ">>> Creating module for $FONT_NAME version $VERSION ($VERSION_CODE)..."

# 1. Prepare Build Directory
mkdir -p "$MODULE_PATH"
cp -r "$TEMPLATE_DIR"/* "$TEMP_BUILD_DIR/"

# 2. Customize module.prop
echo ">>> Customizing module.prop..."
# Create/Overwrite module.prop from template
cat > "$TEMP_BUILD_DIR/module.prop" <<EOF
id=${FONT_NAME// /_}
name=$FONT_NAME
version=$VERSION
versionCode=$VERSION_CODE
author=$AUTHOR
description=Font module for $FONT_NAME (OMF Based)
EOF

# 3. Add font files and rename them
echo ">>> Adding and renaming font files..."
mkdir -p "$TEMP_BUILD_DIR/system/fonts"
cp -r "$FONTS_DIR"/* "$TEMP_BUILD_DIR/system/fonts/"

# Run rename script if it exists, otherwise provide a warning
if [ -f "Scripts/rename_fonts.sh" ]; then
    # Modify rename_fonts.sh to work in the temp directory
    cp Scripts/rename_fonts.sh "$TEMP_BUILD_DIR/rename.sh"
    (cd "$TEMP_BUILD_DIR" && bash rename.sh system/fonts)
    rm "$TEMP_BUILD_DIR/rename.sh"
else
    echo "Warning: Scripts/rename_fonts.sh not found. Fonts might not be correctly named for OMF."
fi

# 4. Package the module
echo ">>> Packaging module into $ZIP_NAME..."
(cd "$TEMP_BUILD_DIR" && zip -r9q "../../$MODULE_PATH/$ZIP_NAME" .)

# 5. Update changelog.md
CHANGELOG_FILE="$MODULE_PATH/changelog.md"
echo ">>> Updating changelog: $CHANGELOG_FILE"
DATE_NOW=$(date +%Y.%m.%d)
if [ -f "$CHANGELOG_FILE" ]; then
    # Prepend new entry
    TEMP_CHANGELOG=$(mktemp)
    echo -e "### $DATE_NOW ($VERSION)\n- $CHANGELOG_MSG\n\n$(cat "$CHANGELOG_FILE")" > "$TEMP_CHANGELOG"
    mv "$TEMP_CHANGELOG" "$CHANGELOG_FILE"
else
    # Create new
    echo -e "### $DATE_NOW ($VERSION)\n- $CHANGELOG_MSG" > "$CHANGELOG_FILE"
fi

# 6. Create/Update update.json
UPDATE_JSON_FILE="$MODULE_PATH/update.json"
echo ">>> Updating update.json..."
# Construct the JSON content (escaped for shell)
cat > "$UPDATE_JSON_FILE" <<EOF
{
  "version": "$VERSION",
  "versionCode": $VERSION_CODE,
  "zipUrl": "https://raw.githubusercontent.com/khirendra03/Font-modules/main/Modules/${FONT_NAME// /%20}/$ZIP_NAME",
  "changelog": "https://raw.githubusercontent.com/khirendra03/Font-modules/main/Modules/${FONT_NAME// /%20}/changelog.md"
}
EOF

# 7. Cleanup
echo ">>> Cleaning up..."
rm -rf "$TEMP_BUILD_DIR"

echo ">>> SUCCESS: Module created at: $MODULE_PATH/$ZIP_NAME"
