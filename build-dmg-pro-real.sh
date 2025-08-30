#!/bin/bash

set -e

PROJECT_NAME="UnplugBlock"
DMG_NAME="UnplugBlock"
TEMP_DIR="dmg-staging"

if [ -f "dmg-config.sh" ]; then
    source dmg-config.sh
else
    WINDOW_WIDTH=600; WINDOW_HEIGHT=600
    ICON_SIZE=120
    APP_ICON_X=120; APP_ICON_Y=250; APPLICATIONS_X=450; APPLICATIONS_Y=250
    BACKGROUND_COLOR="#ffffff"; ACCENT_COLOR="#007AFF"
    APP_TITLE="UnplugBlock"; ARROW_STYLE="➜"; ARROW_SIZE=60
fi

echo "Creating professional DMG with create-dmg..."
echo "Window: ${WINDOW_WIDTH}×${WINDOW_HEIGHT}px"

rm -rf "${TEMP_DIR}"
rm -f "${DMG_NAME}.dmg"

if [ ! -d "${PROJECT_NAME}.app" ]; then
    echo "Compiling application..."
    swift build && ./package-app.sh
fi

mkdir -p "${TEMP_DIR}"
cp -R "${PROJECT_NAME}.app" "${TEMP_DIR}/"

echo "Using existing background image from assets/dmg.png..."

if [ ! -f "assets/dmg.png" ]; then
    echo "ERROR: assets/dmg.png not found!"
    echo "Please ensure the background image exists at assets/dmg.png"
    exit 1
fi

# Check if image needs resizing to match DMG window dimensions
echo "Checking image dimensions..."
IMAGE_INFO=$(sips -g pixelWidth -g pixelHeight assets/dmg.png 2>/dev/null | grep -E "(pixelWidth|pixelHeight)" | awk '{print $2}')
IMAGE_WIDTH=$(echo "$IMAGE_INFO" | head -1)
IMAGE_HEIGHT=$(echo "$IMAGE_INFO" | tail -1)

echo "Current image: ${IMAGE_WIDTH}x${IMAGE_HEIGHT}"
echo "Required size: ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"

# Always resize the image to ensure it fits perfectly
echo "Resizing image to match DMG window dimensions exactly..."
sips -z $WINDOW_HEIGHT $WINDOW_WIDTH assets/dmg.png --out assets/dmg_resized.png
mv assets/dmg_resized.png assets/dmg.png
echo "Image resized to ${WINDOW_WIDTH}x${WINDOW_HEIGHT}"

# Convert to RGB format (remove alpha channel) and fix DPI for better compatibility
echo "Converting image to RGB format and fixing DPI for better compatibility..."
python3 << EOF
from PIL import Image

# Open the image
img = Image.open('assets/dmg.png')

# Convert to RGB (remove alpha channel)
if img.mode in ('RGBA', 'LA', 'P'):
    # Create a white background
    background = Image.new('RGB', img.size, (255, 255, 255))
    if img.mode == 'P':
        img = img.convert('RGBA')
    background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
    img = background
else:
    img = img.convert('RGB')

# Save with correct DPI (72 DPI is standard for web/screen)
img.save('assets/dmg.png', 'PNG', dpi=(72, 72))
print("Image converted to RGB format with 72 DPI")
EOF

# Verify the resize worked
FINAL_INFO=$(sips -g pixelWidth -g pixelHeight assets/dmg.png 2>/dev/null | grep -E "(pixelWidth|pixelHeight)" | awk '{print $2}')
FINAL_WIDTH=$(echo "$FINAL_INFO" | head -1)
FINAL_HEIGHT=$(echo "$FINAL_INFO" | tail -1)
echo "Final image size: ${FINAL_WIDTH}x${FINAL_HEIGHT}"

ls -la assets/dmg.png

echo "Creating DMG with create-dmg..."

create-dmg \
  --volname "UnplugBlock Installer" \
  --background "assets/dmg.png" \
  --window-pos 200 120 \
  --window-size ${WINDOW_WIDTH} ${WINDOW_HEIGHT} \
  --icon-size ${ICON_SIZE} \
  --icon "${PROJECT_NAME}.app" ${APP_ICON_X} ${APP_ICON_Y} \
  --hide-extension "${PROJECT_NAME}.app" \
  --app-drop-link ${APPLICATIONS_X} ${APPLICATIONS_Y} \
  --no-internet-enable \
  --format UDZO \
  "${DMG_NAME}.dmg" \
  "${TEMP_DIR}"

rm -rf "${TEMP_DIR}"

echo ""
echo "PROFESSIONAL DMG CREATED SUCCESSFULLY!"
echo "═══════════════════════════════════════════════"
echo "File: ${DMG_NAME}.dmg"
echo "Size: $(du -h "${DMG_NAME}.dmg" | cut -f1)"
echo ""
echo "FEATURES:"
echo "   • Professional tool: create-dmg"
echo "   • Custom background GUARANTEED"
echo "   • Window: ${WINDOW_WIDTH}×${WINDOW_HEIGHT}px"
echo "   • Icons: ${ICON_SIZE}px"
echo "   • Arrow: ${ARROW_STYLE} in ${ACCENT_COLOR}"
echo "   • Automatic Drag & Drop to Applications"
echo ""
echo "Test: open ${DMG_NAME}.dmg"
echo ""
echo "NOTE: create-dmg is the tool used by"
echo "    applications like Discord, Spotify, Chrome, etc."
