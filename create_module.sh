#!/bin/bash

# Default values
AUTHOR="khirendra03"

# Help message
function show_help {
    echo "Usage: $0 --name <font_name> --version <version> --fonts <path_to_fonts_dir> --changelog <"changelog_message"> [--author <author_name>]"
    echo
    echo "   --name          : Name of the font (e.g., "Roboto")."
    echo "   --version       : Version of the module (e.g., "v1.0")."
    echo "   --fonts         : Path to the directory containing the font files (.ttf or .otf)."
    echo "   --changelog     : A message describing the changes for this version, enclosed in quotes."
    echo "   --author        : (Optional) The name of the module creator. Defaults to 'khirendra03'."
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

# --- Script Execution ---

# Variables
MODULE_DIR="Modules/$FONT_NAME"
ZIP_NAME="${FONT_NAME// /_}[OMF].zip"
TEMP_DIR=$(mktemp -d)

echo "Creating module for $FONT_NAME version $VERSION..."

# 1. Create module directory if it doesn't exist
mkdir -p "$MODULE_DIR"
echo "Module directory: $MODULE_DIR"

# 2. Unpack the template
echo "Unpacking template..."
unzip -q "Template/Font-module-template.zip" -d "$TEMP_DIR"

# 3. Customize module.prop
echo "Customizing module.prop..."
sed -i "s/^id=.*/id=${FONT_NAME// /_}/" "$TEMP_DIR/module.prop"
sed -i "s/^name=.*/name=$FONT_NAME/" "$TEMP_DIR/module.prop"
sed -i "s/^version=.*/version=$VERSION/" "$TEMP_DIR/module.prop"
sed -i "s/^versionCode=.*/versionCode=$(echo $VERSION | tr -d -c 0-9)/" "$TEMP_DIR/module.prop"
sed -i "s/^author=.*/author=$AUTHOR/" "$TEMP_DIR/module.prop"
sed -i "s/^description=.*/description=Font module for $FONT_NAME/" "$TEMP_DIR/module.prop"

# 4. Add font files
echo "Adding font files from $FONTS_DIR..."
cp -r "$FONTS_DIR"/* "$TEMP_DIR/system/fonts/"

# 5. Package the module
echo "Packaging module into $ZIP_NAME..."
(cd "$TEMP_DIR" && zip -r9q "../../$MODULE_DIR/$ZIP_NAME" .)

# 6. Update changelog.md
CHANGELOG_FILE="$MODULE_DIR/changelog.md"
echo "Updating changelog: $CHANGELOG_FILE"
if [ -f "$CHANGELOG_FILE" ]; then
    # Prepend new entry to existing changelog
    echo -e "## $VERSION
- $CHANGELOG_MSG

$(cat "$CHANGELOG_FILE")" > "$CHANGELOG_FILE"
else
    # Create new changelog
    echo -e "## $VERSION
- $CHANGELOG_MSG" > "$CHANGELOG_FILE"
fi

# 7. Create/Update update.json
UPDATE_JSON_FILE="$MODULE_DIR/update.json"
echo "Creating/Updating update.json: $UPDATE_JSON_FILE"
# Construct the JSON content
JSON_CONTENT=$(cat <<EOF
{
  "version": "$VERSION",
  "versionCode": $(echo $VERSION | tr -d -c 0-9),
  "zipUrl": "https://github.com/khirendra03/Font-modules/releases/download/$VERSION/$ZIP_NAME",
  "changelog": "https://raw.githubusercontent.com/khirendra03/Font-modules/main/Modules/${FONT_NAME// /%20}/changelog.md"
}
EOF
)
echo "$JSON_CONTENT" > "$UPDATE_JSON_FILE"


# 8. Cleanup
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Module creation complete!"
echo "Module located at: $MODULE_DIR/$ZIP_NAME"
