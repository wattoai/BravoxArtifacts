#!/bin/bash

APP_NAME="BravoxApp"
STAGING_DIR="dmg-staging"

# Create staging directory
mkdir -p "$STAGING_DIR"
cp -R "$APP_NAME.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDRW temp.dmg

# Mount and customize layout only
hdiutil attach temp.dmg -readwrite -noverify -noautoopen

# Set window appearance and icon positions
osascript << EOF
tell application "Finder"
    tell disk "$APP_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 600, 450}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "$APP_NAME.app" of container window to {150, 200}
        set position of item "Applications" of container window to {400, 200}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Unmount and compress
hdiutil detach "/Volumes/$APP_NAME"
hdiutil convert temp.dmg -format UDZO -imagekey zlib-level=9 -o "$APP_NAME.dmg"

# Clean up
rm temp.dmg
rm -rf "$STAGING_DIR"

echo "DMG created: $APP_NAME.dmg"