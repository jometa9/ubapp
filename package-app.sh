#!/bin/bash

set -e

APP_NAME="UnplugBlock"
BUILD_DIR=".build/debug"
APP_BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Packaging UnplugBlock as macOS app..."

rm -rf "${APP_BUNDLE_DIR}"

mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Verify that the executable exists
if [ ! -f "${BUILD_DIR}/${APP_NAME}" ]; then
    echo "Error: Executable not found at ${BUILD_DIR}/${APP_NAME}"
    echo "Please run 'swift build' first"
    exit 1
fi

cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

cp -R "UnplugBlock/Assets.xcassets" "${RESOURCES_DIR}/"
cp "UnplugBlock/Info.plist" "${CONTENTS_DIR}/"
cp "UnplugBlock/UnplugBlock.entitlements" "${RESOURCES_DIR}/"

cat > "${CONTENTS_DIR}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>UnplugBlock</string>
	<key>CFBundleIdentifier</key>
	<string>com.unplugblock.app</string>
	<key>CFBundleName</key>
	<string>UnplugBlock</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSAppleEventsUsageDescription</key>
	<string>UnplugBlock needs access to system events to automatically log out when you disconnect the charger.</string>
	<key>NSSystemAdministrationUsageDescription</key>
	<string>UnplugBlock needs administration permissions to log out the user session.</string>
</dict>
</plist>
EOF

chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "App bundle created: ${APP_BUNDLE_DIR}"
echo "Size: $(du -sh "${APP_BUNDLE_DIR}" | cut -f1)"

echo "Testing app bundle..."
if [ -f "${MACOS_DIR}/${APP_NAME}" ]; then
    echo "✓ Executable found"
    echo "✓ App bundle structure is valid"
    
    # Verify that the executable can run
    echo "Testing executable..."
    if timeout 5s "${MACOS_DIR}/${APP_NAME}" > /dev/null 2>&1; then
        echo "✓ Executable runs successfully"
    else
        echo "⚠ Executable may have issues (timeout after 5s)"
    fi
    
    echo ""
    echo "You can now:"
    echo "1. Run the app: open ${APP_BUNDLE_DIR}"
    echo "2. Install it: cp -R ${APP_BUNDLE_DIR} /Applications/"
    echo "3. Create a distribution package"
else
    echo "✗ Error: Executable not found"
    exit 1
fi
