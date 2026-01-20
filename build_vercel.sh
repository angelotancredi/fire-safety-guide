#!/bin/bash

# 1. Install Flutter
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Verify Flutter installation
echo "Checking Flutter version..."
flutter --version

# 3. Enable web
flutter config --enable-web

# 4. Get dependencies
echo "Getting dependencies..."
flutter pub get

# 5. Build web
echo "Building Flutter Web..."
flutter build web --release

# 6. Prepare clean output directory
echo "Preparing public directory..."
mkdir -p public
cp -r build/web/* public/
cp vercel.json public/

echo "Build complete! Files are in 'public' directory."
