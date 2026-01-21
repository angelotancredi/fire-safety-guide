#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# 1. Install Flutter
echo "Downloading Flutter SDK..."
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

# 2. Verify Flutter installation
echo "Checking Flutter version..."
flutter --version

# 3. Enable web
echo "Cleaning flutter build..."
flutter clean
flutter config --enable-web

# 4. Get dependencies
echo "Creating .env file from environment variables..."
echo "LAW_API_OC=$LAW_API_OC" > .env
echo ".env file created (Size: $(stat -c%s .env) bytes)"

echo "Getting dependencies..."
flutter pub get

# 5. Build web
echo "Building Flutter Web (Release)..."
flutter build web --release --base-href /

# 6. Prepare dist directory
echo "Preparing dist directory..."
rm -rf dist
cp -r build/web dist

# 7. Verify dist content
echo "Verifying dist/ content:"
ls -la dist/

# Final check for critical assets
if [ ! -f "dist/main.dart.js" ] && [ ! -f "dist/flutter.js" ] && [ ! -f "dist/flutter_bootstrap.js" ]; then
    echo "ERROR: Critical build assets not found in dist/!"
    ls -R dist/
    exit 1
fi

echo "Build complete! Files are in 'dist' directory."
