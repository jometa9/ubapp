#!/bin/bash

set -e

PROJECT_NAME="UnplugBlock"
PROJECT_FILE="UnplugBlock.xcodeproj"
SCHEME="UnplugBlock"
CONFIGURATION="Release"
DISTRIBUTION_DIR="dist"
PACKAGE_NAME="UnplugBlock-v1.0"

function clean_project() {
    echo "Cleaning project..."
    xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration "$CONFIGURATION"
    echo "Project cleaned"
}

function build_project() {
    echo "Building project..."
    xcodebuild build -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration "$CONFIGURATION"
    echo "Build completed"
}

function run_project() {
    echo "Running application..."
    build_project
    
    BUILD_DIR=$(xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration "$CONFIGURATION" -showBuildSettings | grep "BUILT_PRODUCTS_DIR" | awk '{print $3}')
    APP_PATH="$BUILD_DIR/$PROJECT_NAME.app"
    
    if [ -d "$APP_PATH" ]; then
        echo "Launching $APP_PATH"
        open "$APP_PATH"
    else
        echo "Built application not found in $APP_PATH"
        exit 1
    fi
}

function distribute_project() {
    echo "Preparing distribution..."
    
    clean_project
    build_project
    
    rm -rf "$DISTRIBUTION_DIR"
    mkdir -p "$DISTRIBUTION_DIR"
    
    BUILD_DIR=$(xcodebuild -project "$PROJECT_FILE" -scheme "$SCHEME" -configuration "$CONFIGURATION" -showBuildSettings | grep "BUILT_PRODUCTS_DIR" | awk '{print $3}')
    APP_PATH="$BUILD_DIR/$PROJECT_NAME.app"
    
    if [ ! -d "$APP_PATH" ]; then
        echo "Built application not found"
        exit 1
    fi
    
    cp -R "$APP_PATH" "$DISTRIBUTION_DIR/"
    
    cp install.sh "$DISTRIBUTION_DIR/"
    
    cat > "$DISTRIBUTION_DIR/README.txt" << 'EOF'
UnplugBlock - Installation and Configuration
============================================

This application monitors your Mac's charger status and automatically logs out
when you disconnect the charger (after a wait time).

Installation:
Option A - Automatic installation (Recommended):
1. Open Terminal (Applications > Utilities > Terminal)
2. Drag the "install.sh" file to the Terminal window
3. Press Enter and follow the instructions

Option B - Manual installation:
1. Drag "UnplugBlock.app" to your Applications folder
2. Run the application from Applications
3. The first time it runs, macOS will ask for permissions:
   - Security permissions (System Preferences > Security & Privacy)
   - Automation permissions (for logging out)
   - Notification permissions

Configuration:
- The application appears as a lightning icon in the menu bar
- Click on the icon to see status and configure options
- To run automatically on startup:
  System Preferences > Users & Groups > Login Items

Troubleshooting:
- If the application doesn't appear in the menu bar, check if it's running
- If logout doesn't work, check automation permissions
- To uninstall, simply delete the application from Applications

Version: 1.0
Compatibility: macOS 10.15 or higher
EOF

    echo "Distribution prepared in: $DISTRIBUTION_DIR/"
    echo "Contents:"
    ls -la "$DISTRIBUTION_DIR/"
}

function package_project() {
    echo "Creating distribution package..."
    
    distribute_project
    
    cd "$DISTRIBUTION_DIR"
    zip -r "../$PACKAGE_NAME.zip" .
    cd ..
    
    echo "Package created: $PACKAGE_NAME.zip"
    echo "Size: $(du -h "$PACKAGE_NAME.zip" | cut -f1)"
    echo ""
    echo "Ready to share! Send the $PACKAGE_NAME.zip file to other users."
}

function show_help() {
    echo "Build script for UnplugBlock"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  clean      - Clean build files"
    echo "  build      - Build the application"
    echo "  run        - Build and run the application"
    echo "  distribute - Create build for distribution (dist/ folder)"
    echo "  package    - Create ZIP package for sharing"
    echo "  dmg        - Create professional DMG installer (RECOMMENDED)"
    echo "  help       - Show this help"
    echo ""
    echo "To share with other users:"
    echo "  ./build.sh dmg      # Professional installer (recommended)"
    echo "  ./build.sh package  # ZIP package"
    echo ""
    echo "If no command is specified, 'build' will be executed"
}

if [ ! -f "$PROJECT_FILE/project.pbxproj" ]; then
    echo "Error: Project file $PROJECT_FILE not found"
    echo "   Make sure to run this script from the project root directory"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "Error: xcodebuild is not available"
    echo "   Install Xcode and command line tools"
    exit 1
fi

function create_dmg() {
    echo "Creating professional DMG installer..."
    ./build-dmg-simple.sh
}

case "${1:-build}" in
    "clean")
        clean_project
        ;;
    "build")
        build_project
        ;;
    "run")
        run_project
        ;;
    "distribute")
        distribute_project
        ;;
    "package")
        package_project
        ;;
    "dmg")
        create_dmg
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

echo "Done!"

