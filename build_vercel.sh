#!/bin/bash

# 1. Install Flutter
echo "Downloading Flutter SDK..."
rm -rf flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# 2. Verify Flutter installation
echo "Checking Flutter version..."
flutter --version

# 3. Enable web
echo "Cleaning flutter build..."
flutter clean
flutter config --enable-web

# 4. Get dependencies
echo "Getting dependencies..."
flutter pub get

# 5. Build web
echo "Building Flutter Web (Release)..."
flutter build web --release --base-href / --no-pub

# 6. Prepare dist directory
echo "Moving build to dist/..."
rm -rf dist
mkdir -p dist

# Verify build/web content before copying
echo "Checking build/web content:"
ls -la build/web/

cp -rv build/web/* dist/

# 7. Verify dist content
echo "Verifying dist/ content:"
ls -la dist/

# Check for both main.dart.js and fluttering.js (sometimes naming varies)
if [ ! -f "dist/main.dart.js" ] && [ ! -f "dist/flutter.js" ]; then
    echo "ERROR: Critical build assets not found in dist/!"
    find dist/ -maxdepth 2
    exit 1
fi

echo "Build complete! Files are in 'dist' directory."
ls -R dist/
