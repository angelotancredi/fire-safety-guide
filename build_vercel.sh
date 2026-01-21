#!/bin/bash

# 1. Install Flutter
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

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
echo "Building Flutter Web..."
flutter build web --release --base-href /

# 6. Verify output
echo "Checking build output..."
ls -R build/web

echo "Build complete! Files are in 'build/web' directory."
